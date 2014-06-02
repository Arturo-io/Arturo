source 'https://rubygems.org'
source 'https://rails-assets.org'

ruby '2.1.1'

gem 'rails', '~> 4.1.0'
gem 'sass-rails', '>= 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'unicorn'
gem 'pg'
gem 'wdiff'

gem 'foundation-rails', '~> 5.0.0'
gem 'font-awesome-rails'
gem 'kaminari'

gem 'omniauth'
gem 'omniauth-github'
gem 'octokit'
gem 'sidekiq', '~> 2.0'
gem 'docverter'
gem 's3'
gem 'stripe'

gem 'authority'
gem 'pusher'
gem 'intercom-rails', '~> 0.2.24'
gem 'newrelic_rpm'

gem 'rails-assets-momentjs'
gem 'sinatra'

group :development do
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec',  '~> 3.0.0.beta2'
  gem 'rspec-rails',  '~> 3.0.0.beta2'
  gem 'pry'
end

group :test do
  gem 'rspec-sidekiq'
end

group :production do
  gem 'rails_12factor'
end
