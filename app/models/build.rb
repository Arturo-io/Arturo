class Build < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  belongs_to :repo
  has_one :user, through: :repo

end
