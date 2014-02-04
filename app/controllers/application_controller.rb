class ApplicationController < ActionController::Base
  def current_user(sess = session)
    return nil unless sess[:user_id]
    User.find(sess[:user_id])
  end
end
