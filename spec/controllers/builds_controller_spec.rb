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

  context '#index' do
    before do
      create_user(id: 42)
      session[:user_id] = 42
    end

    it 'assigns the correct partial' do
      controller.stub(:user_builds).and_return([])
      get :index 
      expect(assigns(:partial)).to eq('no_builds')

        
      controller.stub(:user_builds).and_return([Build.new])
      get :index 
      expect(assigns(:partial)).to eq('build_list')
    end
  end
end
