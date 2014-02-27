require 'spec_helper'

describe RepositoryController do
  before do 
    create_user(id: 42)
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
      Build.stub(:queue_build)
    end

    it 'calls queue_build for the repo' do
      Build.should_receive(:queue_build).with(99)
      get :build, id: 99 
    end

    it 'does not queue_build if the user does not own the repo' do
      create_user(id: 41, uid: "secondary_user")
      session[:user_id] = 41

      Build.should_not_receive(:queue_build)

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
      RepoSyncWorker.should_receive(:perform_async).with(42)
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
        Build.create(id: 1, repo_id: 1, status: :success)
        Build.create(id: 2, repo_id: 1, status: :failed)
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
      Repo.create(user_id: 42, name: 'test')

      get :index
      expect(response).to render_template('_repo_list')
    end

    it 'assigns the correct repositories' do
      get :index
      assert_not_nil assigns(:repositories)
    end

    it 'assigns a pusher channel' do
      get :index
      assert_not_nil assigns(:pusher_channel)
    end

    it 'only gets the current signed in users repositories' do
      create_user(id: 43)

      Repo.create(user_id: 42, name: 'test')
      Repo.create(user_id: 43, name: 'test_other')

      get :index
      repos = assigns(:repositories) 
      expect(repos.count).to eq(1)
      expect(repos.first[:user_id]).to eq(42)
      expect(repos.first[:name]).to eq('test')
    end

    it 'paginates the repos' do
      Repo.create(user_id: 412, name: 'test') 
      50.times { Repo.create(user_id: 42, name: 'test') }

      get :index
      repos = assigns(:repositories) 
      expect(repos.count).to eq(25)
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
      create_user(id: 41)
      Repo.create(id: 99, user_id: 42, name: 'test')
      Repo.create(id: 11, user_id: 41, name: 'test')
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

      assert_response :forbidden
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
  end

end
