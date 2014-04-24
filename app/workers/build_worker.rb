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

    create_assets(build_id)
    create_diff(build_id) if build.before && build.after
  
    build.reload
    build.update_status(:success)
    build.update(ended_at: Time.now)
  end

  private
  def create_assets(build_id)
    formats = [:pdf, :html, :epub, :mobi]
    assets  = Generate::Book.new(build_id, formats).execute

    assets.each do |asset|
      Asset.create(url: asset, build_id: build_id)
    end
  end

  def create_diff(build_id)
    diff_url = Generate::Build::Diff.new(build_id).execute
    BuildDiff.create(build_id: build_id, url: diff_url)
  end

end
