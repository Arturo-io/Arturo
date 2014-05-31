require 'spec_helper'

describe UsersController do
  render_views

  context '#charge' do

    before do
      @user   = create_user
      @double = double("Stripe::Subscribe").as_null_object
      allow(Stripe::Subscribe).to receive(:new)
        .and_return(@double)

      session[:user_id] = @user.id
    end

    it 'errors when a plan is invalid' do
      post :charge, plan: :something_bad_plan 
      assert_response :forbidden
    end

    it 'redirects to settings page' do
      post :charge, plan: :solo, stripeToken: '1', stripeEmail: 'some_email'
      assert_redirected_to controller: 'users', action: 'settings'
    end

    it 'creates a user subscription' do
      expect(Stripe::Subscribe).to receive(:new)
        .with(plan: "solo", token: "1", email: "some_email", user: @user) 

      post :charge, plan: :solo, stripeToken: '1', stripeEmail: 'some_email'
    end

    it 'flashes an invalid transaction' do
      allow(Stripe::Subscribe).to receive(:new).and_call_original

      expect(Stripe::Customer).to receive(:create) { raise Stripe::CardError }
      post :charge, plan: :solo, stripeToken: '1', stripeEmail: 'some_email'
      expect(flash[:alert]).to eq("Could not complete transaction")
    end
  end

  context '#settings' do
    it 'cant view when not logged in' do
      session[:user_id] = nil
      get :settings
      assert_redirected_to :root
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

      it 'assigns the private repo follow count' do
        repos = 3.times.map { Repo.create(name: 'some repo', user: @user) }
        repos[0].update(private: true)
        repos[1].update(private: true)
        3.times { |i| Follower.create(user: @user, repo: repos[i]) }

        get :settings
        expect(assigns(:private_follow_count)).to eq(2)
      end 

      it 'sets the user email' do
        @user.update(email: 'some@user.com')
        get :settings
        expect(assigns(:email)).to eq("some@user.com")
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
