require 'spec_helper'

describe BuildsController do
  render_views

  context '#user_builds' do
    context 'gets the current users builds only' do
      before do
        user1 = create_user(id: 42, uid: 'user42')
        user2 = create_user(id: 99, uid: 'user99')

        repo1 = Repo.create(id: 41, user: user1) 
        repo2 = Repo.create(id: 98, user: user2) 

        3.times { Build.create(repo: repo1, status: :created) }
        2.times { Build.create(repo: repo2, status: :created) }
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
      allow(double).to receive(:empty?).and_return false
      partial = controller.send(:resolve_partial, double)
      expect(partial).to eq('build_list')
    end

    it 'returns no_builds when builds is empty' do
      double = double()
      allow(double).to receive(:empty?).and_return true
      partial = controller.send(:resolve_partial, double)
      expect(partial).to eq('no_builds')
    end 
  end

  context '#show' do
    before do
      create_user(id: 42)
      create_user(id: 43, uid: "some_other_user")

      Repo.create(id: 99, user_id: 42, full_name: "repo")
      Repo.create(id: 100, user_id: 43, full_name: "repo private", private: true)
      BuildDiff.create(url: 'http://www.example.com', build_id: 1)

      Build.create(id: 1, repo_id: 99, status: :new)
      Build.create(id: 2, repo_id: 100, status: :new)
      Asset.create(url: "http://www.google.com", build_id: 1)

      session[:user_id] = 42
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

    it 'assigns the build diff' do
      get :show, id: 1
      expect(assigns(:diff)[:url]).to eq('http://www.example.com')
    end

    it 'allows for a public repo' do
      session[:user_id] = nil

      get :show, id: 1
      assert_response :success
    end

    it 'forbids for public access to a private repo' do
      session[:user_id] = nil

      get :show, id: 2
      assert_response :forbidden
    end

    it 'allows a owner of the private repo' do
      session[:user_id] = 43

      get :show, id: 2
      assert_response :success
    end

    it 'forbids access to a non-owner user for a private repo' do
      session[:user_id] = 42
      get :show, id: 2
      assert_response :forbidden
    end
  end

  context '#index' do
    before do
      create_user(id: 42)
      session[:user_id] = 42
    end

    it 'assigns build_list when builds is not empty' do
      allow(controller).to receive(:resolve_partial).and_return 'build_list'
      get :index 
      expect(assigns(:partial)).to eq('build_list')
    end

    it 'assings no_builds to partial when empty' do
      allow(controller).to receive(:resolve_partial).and_return 'no_builds'
      get :index 
      expect(assigns(:partial)).to eq('no_builds')
    end

    it 'assigns the pusher_channel' do
      get :index
      expect(assigns(:pusher_channel)).to eq("#{User.find(42).digest}-builds")
    end

    it 'only allows logged in users to view a list' do
      session[:user_id] = nil

      get :index
      assert_response :forbidden
    end

  end
end
