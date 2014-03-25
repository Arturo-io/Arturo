class BuildWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  sidekiq_retries_exhausted do |msg|
    build_id = (msg['args'] && msg['args'].first)
    build    = Build.find(build_id)
    build.update_status(:failure, msg['error_message'])
    FailedBuildEmailWorker.perform_async(build_id) 
  end

  def perform(build_id)
    build = Build.find(build_id)
    build.update_status(:building)

    formats = [:pdf, :html, :epub, :mobi]
    assets  = Generate::Book.new(build_id, formats).execute

    assets.each do |asset|
      Asset.create(url: asset, build: build)
    end

    build.reload
    build.update_status(:success)
    build.update(ended_at: Time.now)
  end

end
