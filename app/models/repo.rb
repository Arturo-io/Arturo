class Repo < ActiveRecord::Base
  include Authority::Abilities

  has_many :followers
  has_many :builds
  belongs_to :user
  
  validates_presence_of :user_id

  default_scope { order("pushed_at DESC") }

  def cancel_builds
    builds = Build
     .where(repo_id: id)
     .where.not(status: [:canceled, :failure, :completed, :success])

    update_builds_status(builds, :canceled)
    cancel_jobs(job_ids(builds))
  end

  def self.user_repositories(user_id, org)
    org ||= User.find(user_id).login
    org.downcase!

    Repo
     .joins("LEFT JOIN followers on followers.repo_id = repos.id")
     .where(user_id: user_id, org: org)
     .reorder("followers.following ASC, pushed_at DESC")
  end

  def self.user_orgs(user_id)
    login = User.find(user_id).login.downcase
    Repo.unscoped.uniq.pluck(:org).tap do |repos|
      repos.delete(login)
    end.compact
  end

  private
  def cancel_jobs(job_ids)
    %w(schedule retry).each { |s| cancel_jobs_in_set(job_ids, s) }
  end

  def cancel_jobs_in_set(job_ids, set_name)
    Sidekiq::SortedSet.new(set_name).each do |job| 
      job.delete if job_ids.include?(job.jid)
    end
  end

  def job_ids(builds)
    builds.map { |b| b.job_id }
  end

  def update_builds_status(builds, status)
    builds.each { |b| b.update_status(status) }
  end

end
