class Repo < ActiveRecord::Base
  include Authority::Abilities

  has_many :followers
  has_many :builds
  belongs_to :user
  
  validates_presence_of :user_id

  default_scope { order("pushed_at DESC") }
end
