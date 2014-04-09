require 'spec_helper'

describe PlanController do
  before do
    create_user(id: 42, uid: 'user42', plan: :multipass, email: 'user@email.com')
    session[:user_id] = 42
  end

  context 'access' do
    it 'allows when logged in' do
      get :show
      assert_response :success
    end

    it 'denies when not logged in' do
      session[:user_id] = nil
      get :show
      assert_response :forbidden
    end
  end


  context 'show' do
    it 'assigns :current_plan' do
      get :show
      expect(assigns(:current_plan)).to eq('multipass')
    end

    it 'assigns :current_plan' do
      get :show
      expect(assigns(:current_plan)).to eq('multipass')
    end

    it 'assigns :stripe_pub_key' do
      get :show
      expect(assigns(:stripe_pub_key)).to eq('none')
    end

    it 'assigns :email' do
      get :show
      expect(assigns(:email)).to eq('user@email.com')
    end

  end
end
