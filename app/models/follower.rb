class Follower < ActiveRecord::Base
  belongs_to :user
  belongs_to :repo

  def self.with_user(user)
    includes(:repo)
      .where(user: user)
  end
end
