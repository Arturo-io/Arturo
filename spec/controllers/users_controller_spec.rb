require 'spec_helper'

describe UsersController do
  render_views

  context '#settings' do
    it 'cant view when not logged in' do
      session[:user_id] = nil
      get :settings
      assert_response :forbidden
    end

    it 'assigns the current user to :user' do
      user = create_user
      session[:user_id] = user.id

      get :settings
      expect(assigns(:user)).to eq(user)
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
