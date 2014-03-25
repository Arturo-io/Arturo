class Notifier < ActionMailer::Base
  default from: "hello@arturo.io"

  def send_signup_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Arturo.io' )
  end

  def send_failed_email(emails, build)
    @build = build
    @repo  = build.repo

    mail(to: emails.first, subject: 'Build failed')
  end

end
