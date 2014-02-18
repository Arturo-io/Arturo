class BuildWorker
 include Sidekiq::Worker
  
  def perform(build_id)
    build = Build.find(build_id)
    build.update(status: :building)

    assets = Generate::Build.new(build_id, [:pdf, :epub, :mobi]).execute

    build.reload
    build.update(status: :completed)
  end

end
