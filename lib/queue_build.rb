class QueueBuild
  attr_reader :repo, :sha, :client, :options

  def initialize(repo_id, options = {})
    @repo    = Repo.find(repo_id) 
    @sha     = options.delete(:sha)
    @options = options
    @client  = self.class.client(repo.user)
  end

  def execute
    create_build_from_github.tap do |build|
      self.class.assign_and_update(build, options)
      cancel_previous_builds
      self.class.perform_async(build)
      self.class.update_status(build)
    end
  end
  
  def create_build_from_github
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

  def commit
    if sha
      Github::Repo.commit(client, repo_full_name, sha)
    else
      Github::Repo.last_commit(client, repo_full_name)
    end
  end

  def cancel_previous_builds
    repo.cancel_builds
  end

  private
  def repo_full_name
    repo[:full_name]
  end

  def self.perform_async(build)
    job_id = BuildWorker.perform_async(build[:id])
    build.update(job_id: job_id)
  end

  def self.assign_and_update(build, options)
    build.update(options)
  end

  def self.update_status(build)
    status = BuildStatus.new(build)
    Pusher.trigger(status.new_pusher_channel, 'new', status.render_string)
  end

  def self.client(user)
    Octokit::Client.new(access_token: user[:auth_token])
  end

  def self.queue_build(*args)
    self.new(*args).execute
  end
end
