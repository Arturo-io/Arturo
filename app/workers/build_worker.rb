class BuildWorker
 include Sidekiq::Worker
  
  def perform(repo_id)
    assets = Generate::Build.new(repo_id, [:pdf, :epub, :mobi]).execute
  end

end
