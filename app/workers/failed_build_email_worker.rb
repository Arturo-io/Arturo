class FailedBuildEmailWorker  
 include Sidekiq::Worker
  
  def perform(build_id)
    build  = Build.find(build_id)
    emails = [build.user.email]

    Notifier.send_failed_email(emails, build).deliver
  end

end
