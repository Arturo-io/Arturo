class UsersController < ApplicationController 
  before_filter :check_login, only: [:settings]
  before_filter :validate_plan, only: [:charge]

  def logout
    reset_session
    redirect_to root_path
  end

  def settings
    @user          = current_user
    @build_count   = build_count
    @follow_count  = follow_count
    @private_follow_count = private_follow_count
    @email         = current_user[:email]
  end

  def charge
    options = { token: params[:stripeToken], 
                email: params[:stripeEmail],
                user:  current_user,
                plan:  params[:plan] }

    Stripe::Subscribe.new(options).execute
  rescue
    flash[:alert] = "Could not complete transaction"
  ensure
    redirect_to user_settings_path
  end

  private
  def validate_plan
    unless valid_plan?(params[:plan])
      render status: :forbidden, nothing: true 
    end
  end

  def valid_plan?(plan_name) 
    Plan.find_by(name: plan_name) || false
  end

  def private_follow_count(user = current_user)
    follows(user, true).count
  end

  def follow_count(user = current_user)
    follows(user).count
  end

  def follows(user = current_user, private_only = false)
    options = { user_id: user.id }
    options[:private] = true if private_only

    Follower
      .includes(:repo)
      .where(repos: options) 
  end


  def build_count(user = current_user)
    Build.user_builds(user).count
  end
end
