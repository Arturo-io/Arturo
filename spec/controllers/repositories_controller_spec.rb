require 'spec_helper'

describe RepositoriesController do
  render_views

  before do 
    create_user(id: 42, login: "ortuna")
    session[:user_id] = 42
  end

  context '#check_login' do
    it 'requires a user to be logged in' do
      session[:user_id] = nil
      get :sync;  assert_response :forbidden
      get :index; assert_response :forbidden

      get :follow,   id: 1; assert_response :forbidden
      get :unfollow, id: 1; assert_response :forbidden
    end
  end

  context '#build' do
    before do
      Repo.create(id: 99, user_id: 42, name: 'test')
      allow(QueueBuild).to receive(:queue_build)
    end

    it 'calls queue_build for the repo' do
      expect(QueueBuild).to receive(:queue_build).with(99)
      get :build, id: 99 
    end

    it 'does not queue_build if the user does not own the repo' do
      create_user(id: 41, uid: "secondary_user")
      session[:user_id] = 41

      expect(QueueBuild).to_not receive(:queue_build)

      get :build, id: 99 
      assert_response :forbidden
    end

    it 'redirects you to the repository path' do
      get :build, id: 99 
      assert_redirected_to repositories_show_path(99)
    end
  end

  context '#sync' do
    it 'sets the users loading_repos to true' do
      get :sync
      user = User.find(42)
      expect(user[:loading_repos]).to eq(true)
    end
    
    it 'cant double sync' do
      user = User.find(42)
      user.update(loading_repos: true)
      get :sync
      expect(flash[:alert]).not_to be_nil
    end

    it 'calls #perform_async with the correct user_id' do
      expect(RepoSyncWorker).to receive(:perform_async).with(42)
      get :sync
    end

    it 'queues up a job' do
      get :sync
      expect(RepoSyncWorker).to have(1).job
    end

    it 'redirects you to repo list' do
      get :sync
      assert_redirected_to repositories_path
    end

  end

  context '#show' do

    before do 
      Repo.create(id: 1, user_id: 42, name: 'some_repo', private: false)
      Repo.create(id: 2, user_id: 42, name: 'private', private: true)
    end

    it 'finds the right repo' do
      get :show, id:  1
      expect(assigns(:repo)[:name]).to eq("some_repo")
    end

    it 'shows a public repo to anon. users' do
      session[:user_id] = nil 

      get :show, id: 1
      assert_response :success
    end

    it 'denies a private repo to anon users' do
      session[:user_id] = nil 

      get :show, id: 2 
      assert_response :forbidden
    end

    it 'assigns the last 5 builds for that repo' do
      10.times { Build.create(repo_id: 1, status: :success) }

      get :show, id: 1
      expect(assigns(:builds)).not_to be_nil
      expect(assigns(:builds).count).to eq(5)
    end

    it 'assings a badge markdown value' do
      get :show, id: 1

      expect(assigns(:badge_markdown)).to match(/badge\/1/)
      expect(assigns(:badge_markdown)).to match(/repositories\/1/)
    end
    
    context 'last build and assets' do
      before do
        Build.create(id: 1, repo_id: 1, status: :success, branch: :master)
        Build.create(id: 2, repo_id: 1, status: :failed,  branch: :mnaster)
        Asset.create(build_id: 1, url: 'http://www.google.com')
      end

      it 'assigns the latest assets' do
        get :show, id: 1
        last_assets = assigns(:last_assets)
        expect(last_assets.first[:url]).to eq('http://www.google.com')
      end

      it 'assigns the latest build' do
        get :show, id: 1

        last_build = assigns(:last_build)
        expect(last_build[:id]).to eq(1)
      end
    end
  end

  context '#index' do
    render_views
    it 'renders a no repos template when repos are empty' do
      get :index
      expect(response).to render_template('_no_repos')
    end

    it 'renders a list of repos' do
      Repo.create(user_id: 42, name: 'test', org: "ortuna")

      get :index
      expect(response).to render_template('_repo_list')
    end

    it 'assigns the correct repositories' do
      get :index
      expect(assigns(:repositories)).not_to be_nil
    end

    it 'assigns a pusher channel' do
      get :index
      expect(assigns(:pusher_channel)).not_to be_nil
    end

    it 'assigns the users orgs' do
      get :index
      expect(assigns(:orgs)).not_to be_nil
    end

    it 'assigns the users login to the org' do
      get :index
      expect(assigns(:org)).to eq('ortuna')
    end

    it 'assigns the org' do
      get :index, org: 'some_org'
      expect(assigns(:org)).to eq('some_org')
    end
    

    it 'only gets the current signed in users repositories' do
      create_user(id: 43, uid: 43)

      Repo.create(user_id: 42, name: 'test', org: "ortuna")
      Repo.create(user_id: 43, name: 'test_other', org: "ortuna")

      get :index
      repos = assigns(:repositories) 
      expect(repos.count).to eq(1)
      expect(repos.first[:user_id]).to eq(42)
      expect(repos.first[:name]).to eq('test')
    end

    it 'paginates the repos' do
      Repo.create(user_id: 412, name: 'test', org: "ortuna") 
      50.times { Repo.create(user_id: 42, name: 'test', org: "ortuna") }

      get :index
      repos = assigns(:repositories) 
      expect(repos.count).to eq(25)
    end

    context 'Org list tabs' do
      it 'doesnt render the orgs tabs when repos are empty' do
        subject = get(:index)
        expect(subject).not_to render_template("repositories/_org_list")
      end

      it 'render the orgs tabs when there are repos' do
        Repo.create(user_id: 42, name: 'test', org: "ortuna")

        subject = get(:index)
        expect(subject).to render_template("repositories/_org_list")
      end
    end

    context 'followers' do
      it 'assigns a list of repo ids that are being followed' do
        Repo.create(id: 99, user_id: 42, name: 'test')
        Follower.create(user_id: 42, repo_id: 99)

        get :index
        following = assigns(:following)
        expect(following).not_to be_nil

        expect(following.include?(99)).to eq(true)
      end

      it 'assigns an empty array when nothing is followed' do
        get :index
        following = assigns(:following)
        expect(following).to eq([])
      end

    end
  end

  context 'follow/unfollow'  do
    before do
      create_user(id: 41, uid: "other")
      Repo.create(id: 99, user_id: 42, name: 'test')
      Repo.create(id: 11, user_id: 41, name: 'test')
      Repo.create(id: 33, user_id: 42, name: 'test', private: true)
    end

    it 'can follow a repo' do
      put :follow, id: 99 
      expect(Follower.where(repo_id: 99, user_id: 42).count).to eq(1)

    end
    it 'creates a job for removing a hook on unfollow' do
      Follower.create(user_id: 42, repo_id: 99)

      delete :unfollow, id: 99
      expect(GithubRemoveHookWorker).to have(1).job
    end

    it 'creates a job for adding a hook on follow' do
      put :follow, id: 99
      expect(GithubCreateHookWorker).to have(1).job
    end

    it 'cant follow someone elses repo' do
      put :follow, id: 11 
      expect(Follower.where(repo_id: 99, user_id: 42).count).to eq(0)
    end

    it 'has a notice for a follow' do
      put :follow, id: 99
      expect(flash[:notice]).to match(/test/)
    end

    it 'has a notice for a follow' do
      Follower.create(user_id: 42, repo_id: 99)

      delete :unfollow, id: 99
      expect(flash[:notice]).to match(/test/)
    end

    it 'can unfollow a repo' do
      Follower.create(user_id: 42, repo_id: 99)

      delete :unfollow, id: 99 
      expect(Follower.where(repo_id: 99, user_id: 42).count).to eq(0)
    end

    it 'redirects after a follow and unfollow' do
      put :follow, id: 99 
      assert_redirected_to repositories_path

      delete :unfollow, id: 99 
      assert_redirected_to repositories_path
    end

    context 'private repo limits' do
      it 'does not allow following on a limited plan' do
        put :follow, id: 33 
        expect(Follower.where(repo_id: 33, user_id: 42).count).to eq(0)
      end

      it 'sets the flash error message' do 
        msg = 'You have reached your private repo limit, please upgrade your account on the settings page.'
        put :follow, id: 33 
        expect(flash[:alert]).to eq(msg)
      end

      it 'redirects to repos_path' do
        put :follow, id: 33 
        assert_redirected_to repositories_path
      end

    end
  end

  context '#latest' do
    before do 
      repo  = Repo.create(id: 99, user_id: 42, name: 'test')
      build = Build.create(id: 41, repo: repo, status: :success, branch: :master) 
      Asset.create(build: build, url: 'http://google.com/something.pdf')
    end

    it 'returns the latest asset of said type' do
      get :last_build, id: 99, format: :pdf
      asset = assigns(:asset)
      expect(asset.url).to eq('http://google.com/something.pdf')
    end

    it 'redirects to the lastest asset' do
      get :last_build, id: 99, format: :pdf
      assert_redirected_to 'http://google.com/something.pdf'
    end

    it 'finds mangled format' do
      get :last_build, id: 99, format: :PdF
      assert_redirected_to 'http://google.com/something.pdf'
    end

    it 'gives 404 when asset is not found' do
      get :last_build, id: 99, format: :elephant
      assert_response :not_found
    end

    it 'gives anon user access to public build' do
      session[:user_id] = nil 

      get :last_build, id: 99, format: :PdF
      assert_redirected_to 'http://google.com/something.pdf'
    end

    it 'authorizes a user' do
      session[:user_id] = nil 
      Repo.find(99).update(private: true)

      get :last_build, id: 99, format: :pdf
      assert_response :forbidden
    end

  end
end
