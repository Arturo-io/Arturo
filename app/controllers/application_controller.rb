class ApplicationController < ActionController::Base
  before_filter :current_user

  def check_login
    head :forbidden unless current_user && current_user[:id]
  end

  def current_user(sess = session)
    return User.new unless sess[:user_id]
    @user ||= User.find(sess[:user_id])
  end
end
