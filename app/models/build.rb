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

  private
  def build_status
    BuildStatus.new(self) 
  end

  class << self
    def queue_build(repo_id, options = {})
      repo = Repo.find(repo_id) 
      sha  = options.delete(:sha)
      from_github(client(repo.user), repo_id, sha).tap do |build|
        build.assign_attributes(options)
        build.save
        
        repo.cancel_builds

        job_id = BuildWorker.perform_async(build[:id])
        build.update(job_id: job_id)
        
        update_status(build)
      end
    end

    def from_github(client, repo_id, sha)
      repo   = Repo.find(repo_id) 
      commit = github_commit(client, repo[:full_name], sha)

      Build.new(branch:        repo[:default_branch],
                repo:          repo,
                started_at:    Time.now,
                commit:        commit.sha,
                author:        commit.author.login,
                author_url:    commit.author.rels[:html].href,
                author_avatar: commit.author.rels[:avatar].href,
                message:       commit.commit.message,
                commit_url:    commit.rels[:html].href,
                status:        :queued)
    end

    private
    def github_commit(client, repo, sha = nil)
      if sha
        Github::Repo.commit(client, repo, sha)
      else
        Github::Repo.last_commit(client, repo)
      end
    end

    def update_status(build)
      status = BuildStatus.new(build)
      Pusher.trigger(status.pusher_channel, 'new', status.render_string)
    end

    def client(user)
      Octokit::Client.new(access_token: user[:auth_token])
    end
  end


end
