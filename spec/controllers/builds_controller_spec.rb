require 'spec_helper'

describe BuildController do
  context '#user_builds' do
    context 'gets the current users builds only' do
      before do
        user1 = create_user(id: 42, uid: 'user42')
        user2 = create_user(id: 99, uid: 'user99')

        repo1 = Repo.create(id: 41, user: user1) 
        repo2 = Repo.create(id: 98, user: user2) 

        3.times { Build.create(repo: repo1) }
        2.times { Build.create(repo: repo2) }
      end

      it 'gets user 42s repos' do
        session[:user_id] = 42
        get :index
        expect(assigns(:builds).count).to eq(3)
        expect(assigns(:builds).first.repo[:id]).to eq(41)
      end

      it 'gets user 99s repos' do
        session[:user_id] = 99 
        get :index
        expect(assigns(:builds).count).to eq(2)
        expect(assigns(:builds).first.repo[:id]).to eq(98)
      end
    end
  end 

  context '#resolve_partial' do
    it 'returns no_builds when builds is empty' do
      double = double()
      double.stub(:empty?).and_return false
      partial = controller.send(:resolve_partial, double)
      expect(partial).to eq('build_list')
    end

    it 'returns no_builds when builds is empty' do
      double = double()
      double.stub(:empty?).and_return true
      partial = controller.send(:resolve_partial, double)
      expect(partial).to eq('no_builds')
    end 
  end

  context '#show' do
    before do
      create_user(id: 42)
      session[:user_id] = 42

      Repo.create(id: 99, user_id: 42, full_name: "repo")
      Build.create(id: 1, repo_id: 99, status: :new)
      Asset.create(url: "http://www.google.com", build_id: 1)
    end

    it 'assigns the build' do
      get :show, id: 1
      expect(assigns(:build)[:status]).to eq("new")
    end

    it 'assigns the repo' do
      get :show, id: 1
      expect(assigns(:repo)[:full_name]).to eq("repo")
    end

    it 'assigns the assets' do
      get :show, id: 1
      expect(assigns(:assets).first[:url]).to eq("http://www.google.com")
    end

  end

  context '#index' do
    before do
      create_user(id: 42)
      session[:user_id] = 42
    end

    it 'assigns build_list when builds is not empty' do
      controller.stub(:resolve_partial).and_return 'build_list'
      get :index 
      expect(assigns(:partial)).to eq('build_list')
    end

    it 'assings no_builds to partial when empty' do
      controller.stub(:resolve_partial).and_return 'no_builds'
      get :index 
      expect(assigns(:partial)).to eq('no_builds')
    end

    it 'assigns the pusher_channel' do
      get :index
      expect(assigns(:pusher_channel)).to eq("#{User.find(42).digest}-builds")
    end


  end
end
