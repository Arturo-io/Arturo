class QueueBuildWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(repo_id)
    QueueBuild.queue_build(repo_id)
  end
end
