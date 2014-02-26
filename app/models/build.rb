class Build < ActiveRecord::Base
  include Authority::Abilities

  default_scope { order(created_at: :desc) }

  belongs_to :repo
  has_one    :user, through: :repo
  has_many   :assets
  

  def self.queue_build(repo_id, sha = nil)
    repo   = Repo.find(repo_id) 
    build  = from_github(client(repo.user), repo_id, sha)
    build.save
    
    repo.cancel_builds

    job_id = BuildWorker.perform_async(build[:id])
    build.update(job_id: job_id)
    
    status = BuildStatus.new(build)
    Pusher.trigger(status.pusher_channel, 'new', status.render_string)
  end

  def self.from_github(client, repo_id, sha)
    repo   = Repo.find(repo_id) 
    commit = Github::Repo.commit(client, repo[:full_name], sha)

    Build.new(branch:     repo[:default_branch],
              repo:       repo,
              started_at: Time.now,
              commit:     commit.sha,
              author:     commit.author.login,
              message:    commit.commit.message,
              commit_url: commit.rels[:html].href,
              status:     :queued)

  end

  def self.client(user)
    Octokit::Client.new(access_token: user[:auth_token])
  end

  def update_status(status, message = nil)
    build_status.update(status, message)
  end

  private
  def build_status
    BuildStatus.new(self) 
  end
end
