require 'spec_helper'

describe UsersController do
  render_views

  context '#settings' do
    it 'cant view when not logged in' do
      session[:user_id] = nil
      get :settings
      assert_response :forbidden
    end

    context 'with user' do
      before do
        @user = create_user
        session[:user_id] = @user.id
      end

      it 'assigns the current user to :user' do
        get :settings
        expect(assigns(:user)).to eq(@user)
      end

      it 'assigns a build count' do
        repo = Repo.create(name: 'some repo', user: @user)
        5.times { Build.create(repo: repo) }

        get :settings
        expect(assigns(:build_count)).to eq(5)
      end

      it 'assigns the repo count' do
        repos = 3.times.map { Repo.create(name: 'some repo', user: @user) }
        3.times { |i| Follower.create(user: @user, repo: repos[i]) }

        get :settings
        expect(assigns(:follow_count)).to eq(3)
      end
    end
  end

  context "#logout" do
    it "clears the user session" do
      session[:stuff] = "some_value"
      get :logout
      expect(session[:stuff]).to eq(nil)
    end
  end
end
