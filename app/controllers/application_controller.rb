class ApplicationController < ActionController::Base
  def check_login
    head :forbidden unless current_user
  end

  def current_user(sess = session)
    return nil unless sess[:user_id]
    @user ||= User.find(sess[:user_id])
  end
end
