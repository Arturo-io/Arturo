class RepoSyncWorker
 include Sidekiq::Worker
  
  def perform(user_id)
    Github::Repo.sync(user_id)
    user = User.find(user_id)
    user.update(loading_repos: false, last_sync_at: Time.now)

    Pusher.trigger(user.digest, 'sync_complete', {completed: true})
  end
end
