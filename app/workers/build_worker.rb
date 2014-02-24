class BuildWorker
 include Sidekiq::Worker
  
  def perform(build_id)
    build = Build.find(build_id)
    build.update_status(:building)

    assets = Generate::Build.new(build_id, [:pdf, :epub, :mobi]).execute
    assets.each do |asset|
      Asset.create(url: asset, build: build)
    end

    build.reload
    build.update_status(:success)
    build.update(ended_at: Time.now)
  end

end
