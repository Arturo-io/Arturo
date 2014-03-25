class Notifier < ActionMailer::Base
  default from: "hello@arturo.io"

  def send_signup_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Arturo.io' )
  end

end
