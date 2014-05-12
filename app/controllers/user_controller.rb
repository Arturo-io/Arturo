class UserController < ApplicationController 
  def logout
    reset_session
    redirect_to root_path, notice: "You have been logged out"
  end

  def settings
    @user = current_user
  end
end
