class Build < ActiveRecord::Base
  include Authority::Abilities

  default_scope { order(created_at: :desc) }

  belongs_to :repo
  has_one    :user, through: :repo
  has_many   :assets
  
  def update_status(status)
    BuildStatus.new(self).update(status)
  end

  def self.queue_build(repo_id)
    repo   = Repo.find(repo_id) 
    build  = from_github(client(repo.user), repo_id)
    build.save
    
    repo.cancel_builds

    job_id = BuildWorker.perform_async(build[:id])
    build.update(job_id: job_id)
    
    status = BuildStatus.new(build)
    Pusher.trigger(status.pusher_channel, 'new', status.render_string)
  end

  def self.from_github(client, repo_id)
    repo          = Repo.find(repo_id) 
    latest_commit = Github::Repo.last_commit(client, repo[:full_name])
    Build.new(branch: repo[:default_branch],
              repo:   repo,
              started_at: Time.now,
              commit: latest_commit.sha,
              author: latest_commit.author.login,
              message: latest_commit.commit.message,
              commit_url: latest_commit.rels[:html].href,
              status: :queued)

  end

  def self.client(user)
    Octokit::Client.new(access_token: user[:auth_token])
  end

end
