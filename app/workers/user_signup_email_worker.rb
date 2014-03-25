class UserSignupEmailWorker
 include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    Notifier.send_signup_email(user)
  end
end
