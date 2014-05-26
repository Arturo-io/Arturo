class UsersController < ApplicationController 
  before_filter :check_login, only: [:settings]

  def logout
    reset_session
    redirect_to root_path, notice: "You have been logged out"
  end

  def settings
    @user = current_user
  end
end
