# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end

def create_user(options = {})
  options = { 
    uid: 1,
    id:  1,
    provider: 'github',
    name: 'test user',
    auth_token: 'token',
  }.merge(options)
  User.create!(options)
end

def create_repo(options = {})
  Repo.create(options)
end

def create_build(options = {})
  options = { 
    author: "some_author",
    author_url: "some_url",
    author_avatar: "some_avatar",
    commit: "some_commit",
    commit_url: "some_commit",
    status: :queued
  }.merge(options)
  Build.create(options)
end

def read_fixture_file(path)
  File.read("#{Rails.root}/spec/fixtures/#{path}")
end

Authority.configure do |config|
  config.logger = Logger.new('/dev/null')
end

Sidekiq::Logging.logger = nil
