class ApplicationController < ActionController::Base
  before_filter :current_user

  def check_login
    kick_to_homepage unless current_user && current_user[:id]
  end

  def current_user(sess = session)
    return User.new unless sess[:user_id]
    @user ||= User.find(sess[:user_id])
  end

  private
  def kick_to_homepage
    redirect_to :root
  end
end
