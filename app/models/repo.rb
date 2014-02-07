class Repo < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :user
  has_many :followers

  default_scope { order("pushed_at DESC") }
end
