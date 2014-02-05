class RepoSyncWorker
 include Sidekiq::Worker
  
  def perform(user_id)
    Github::Repo.sync(user_id)
  end
end
