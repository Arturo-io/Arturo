class GithubCreateHookWorker 
 include Sidekiq::Worker
  
  def perform(repo_id)
    hook = Github::Hook.create_hook(repo_id)
    Repo.find(repo_id).update(hook_id: hook[:id])
  end

end
