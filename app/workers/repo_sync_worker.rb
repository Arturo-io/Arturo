class RepoSyncWorker
 include Sidekiq::Worker
  
  def perform(user_id)
    Github::Repo.sync(user_id)
    user = User.find(user_id)
    user.update(loading_repos: false)
  end
end