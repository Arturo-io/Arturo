class UsersController < ApplicationController 
  before_filter :check_login, only: [:settings]
  before_filter :validate_plan, only: [:charge]

  def logout
    reset_session
    redirect_to root_path, notice: "You have been logged out"
  end

  def settings
    @user        = current_user
    @build_count = build_count
    @follow_count  = follow_count
  end

  def charge
    options = { token: params[:stripeToken], 
                email: params[:stripeEmail],
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

  def follow_count(user = current_user)
    Follower
      .includes(:repo)
      .where(repos: { user_id: user.id}) 
      .count
  end

  def build_count(user = current_user)
    Build.user_builds(user).count
  end
end
