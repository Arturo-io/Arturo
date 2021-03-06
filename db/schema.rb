# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140527015120) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assets", force: true do |t|
    t.integer  "build_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "build_diffs", force: true do |t|
    t.integer  "build_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "builds", force: true do |t|
    t.integer  "repo_id"
    t.string   "status"
    t.string   "branch"
    t.string   "commit"
    t.string   "author"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
    t.string   "commit_url"
    t.string   "job_id"
    t.text     "error"
    t.string   "author_avatar"
    t.string   "author_url"
    t.string   "before"
    t.string   "after"
  end

  create_table "followers", force: true do |t|
    t.integer "user_id"
    t.integer "repo_id"
    t.boolean "following", default: true
  end

  create_table "plans", force: true do |t|
    t.string   "name"
    t.integer  "repos"
    t.boolean  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.integer  "price"
    t.string   "stripe_description"
  end

  create_table "repos", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "full_name"
    t.boolean  "private"
    t.text     "description"
    t.integer  "github_id"
    t.integer  "github_user_id"
    t.boolean  "fork"
    t.string   "default_branch"
    t.string   "homepage"
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hook_id"
    t.string   "html_url"
    t.string   "org"
  end

  create_table "users", force: true do |t|
    t.string   "uid"
    t.string   "provider"
    t.string   "name"
    t.string   "auth_token"
    t.string   "image_url"
    t.string   "role"
    t.string   "login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_sync_at"
    t.boolean  "loading_repos",             default: false
    t.string   "email"
    t.string   "stripe_token"
    t.integer  "plan_id"
    t.string   "stripe_customer_token"
    t.string   "stripe_subscription_token"
  end

end
