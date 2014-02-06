class Repo < ActiveRecord::Base
  belongs_to :user
  default_scope { order("pushed_at DESC") }
end
