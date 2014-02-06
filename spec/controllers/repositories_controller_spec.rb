require 'spec_helper'

describe RepositoriesController do
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
  end
end
