class Build < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  belongs_to :repo
  has_one :user, through: :repo
  
  def self.queue_build(repo_id)
    repo   = Repo.find(repo_id) 
    client = Octokit::Client.new(access_token: repo.user[:auth_token])
    build  = from_github(client, repo_id)
    build.save

    BuildWorker.perform_async(build[:id])
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
                      status: :queued)

  end
end
