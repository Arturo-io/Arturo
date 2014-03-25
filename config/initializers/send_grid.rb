ActionMailer::Base.smtp_settings = {
  user_name: Rails.configuration.sendgrid_user,
  password: Rails.configuration.sendgrid_password,
  domain: 'arturo.io',
  address: 'smtp.sendgrid.net',
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}
