class GithubRemoveHookWorker 
 include Sidekiq::Worker
 sidekiq_options retry: 1
  
  def perform(repo_id)
    Github::Hook.remove_hook(repo_id)
    Repo.find(repo_id).update(hook_id: nil)
  end

end
