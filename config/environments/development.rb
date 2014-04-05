Arturo::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.github_key    = ENV['GITHUB_KEY']    || '65279e1360471fcf2d73'
  config.github_secret = ENV['GITHUB_SECRET'] || '9867ebd1f13ab22316d67293e7f85ffa7c289dd0'

  config.s3_bucket = ENV['S3_BUCKET'] || 'arturo_dev'
  config.s3_key    = ENV['S3_KEY']    || 'AKIAIXR5BBJJSSNZHVSA'
  config.s3_secret = ENV['S3_SECRET'] || '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'

  config.pusher_app_id = ENV['PUSHER_APP_ID'] || '65611'
  config.pusher_key    = ENV['PUSHER_KEY']    || '3f0c6e069a53455c4c74'
  config.pusher_secret = ENV['PUSHER_SECRET'] || 'c22d241a491bdbc7e0b6'

  config.sendgrid_user     = 'arturo-dev'
  config.sendgrid_password = 'arturod3v3r'

  config.stripe_key     = ENV['STRIPE_KEY']     || 'sk_test_M52ZOC19WtH7P0ZCMpXTRPg4'
  config.stripe_pub_key = ENV['STRIPE_PUB_KEY'] || 'pk_test_vo6p4bqMHJGvbbtDSZUX25du'
end
