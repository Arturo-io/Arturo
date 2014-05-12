require 'spec_helper'

describe UserController do
  render_views

  context '#settings' do
    it 'sets the user object' do
      get :settings
      expect(assigns(:user)).not_to be_nil
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
