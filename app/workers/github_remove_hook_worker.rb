class GithubRemoveHookWorker 
 include Sidekiq::Worker
  
  def perform(repo_id)
    Github::Hook.remove_hook(repo_id)
    Repo.find(repo_id).update(hook_id: nil)
  end

end
