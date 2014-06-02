class GithubCreateHookWorker 
 include Sidekiq::Worker
 sidekiq_options retry: 1
 
  def perform(repo_id)
    hook = Github::Hook.create_hook(repo_id)
    Repo.find(repo_id).update(hook_id: hook[:id])
  rescue 
    Notifier.send_failed_hook_create(repo_id)
  end

end
