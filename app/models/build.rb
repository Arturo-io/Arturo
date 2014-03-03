class Build < ActiveRecord::Base
  include Authority::Abilities

  default_scope { order(created_at: :desc) }

  belongs_to :repo
  has_one    :user, through: :repo
  has_many   :assets
  
  def update_status(status, message = nil)
    build_status.update(status, message)
  end

  def assign_attributes(attributes)
    attributes.each { |key, value| send("#{key}=", value) }
  end

  def self.last_successful_build(repo_id, branch = :master)
    where(repo_id: repo_id, branch: branch, status: :success).first
  end

  private
  def build_status
    BuildStatus.new(self) 
  end
end
