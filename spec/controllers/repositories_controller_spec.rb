require 'spec_helper'

describe RepositoriesController do
  context '#sync' do
    before {  create_user(id: 42) }
    it 'calls #perform_async with the correct user_id' do
      session[:user_id] = 42
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
    it 'assigns the correct repositories' do
      get :index
      assert_not_nil assigns(:repositories)
    end

    it 'only gets the current signed in users repositories' do
      create_user(id: 42)
      create_user(id: 43)

      Repo.create(user_id: 42, name: 'test')
      Repo.create(user_id: 43, name: 'test_other')

      session[:user_id] = 42
      get :index
      repos = assigns(:repositories) 
      expect(repos.count).to eq(1)
      expect(repos.first[:user_id]).to eq(42)
      expect(repos.first[:name]).to eq('test')
    end

    it 'paginates the repos' do
      create_user(id: 42)
      Repo.create(user_id: 412, name: 'test') 
      50.times { Repo.create(user_id: 42, name: 'test') }

      session[:user_id] = 42
      get :index
      repos = assigns(:repositories) 
      expect(repos.count).to eq(25)
    end
  end
end
