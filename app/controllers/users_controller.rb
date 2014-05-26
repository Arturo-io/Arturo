class UsersController < ApplicationController 
  before_filter :check_login, only: [:settings]

  def logout
    reset_session
    redirect_to root_path, notice: "You have been logged out"
  end

  def settings
    @user        = current_user
    @build_count = build_count
    @follow_count  = follow_count
  end

  private
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
