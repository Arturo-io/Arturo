class Repo < ActiveRecord::Base
  belongs_to :user
  has_many :followers

  default_scope { order("pushed_at DESC") }
end
