require 'spec_helper'

describe UserController do
  context "#logout" do
    it "clears the user session" do
      session[:stuff] = "some_value"
      get :logout
      expect(session[:stuff]).to eq(nil)
    end
  end
end
