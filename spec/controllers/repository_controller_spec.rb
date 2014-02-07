require 'spec_helper'

describe RepositoryController do
  before do 
    create_user(id: 42)
    session[:user_id] = 42
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
      Repo.create(id: 99, user_id: 42, name: 'test')
    end

    it 'can follow a repo' do
      put :follow, id: 99 
      expect(Follower.where(repo_id: 99, user_id: 42).count).to eq(1)
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
