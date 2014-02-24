class Build < ActiveRecord::Base
  include Authority::Abilities

  default_scope { order(created_at: :desc) }

  belongs_to :repo
  has_one    :user, through: :repo
  has_many   :assets
  
  def update_status(status)
    update(status: status) 
    Pusher.trigger(pusher_channel, 'status_update', {id: id, status: status_html(status)})
  end

  def pusher_channel
    user.digest << "-builds"
  end

  def render_string
    view = ActionView::Base.new(Rails.configuration.paths["app/views"])
    view.extend BuildHelper
    view.extend FontAwesome::Rails::IconHelper
    view.extend ActionView::Helpers
    view.extend Rails.application.routes.url_helpers
    view.extend ActionDispatch::Routing::UrlFor
    view.class_eval do
      def default_url_options; {} end
    end

    view.render(:partial => 'build/build_list_single', locals: { build: self })
  end
  
  def status_html(status)
    view = ActionView::Base.new(Rails.configuration.paths["app/views"])
    view.extend BuildHelper
    view.extend FontAwesome::Rails::IconHelper
    view.extend ActionView::Helpers
    view.extend Rails.application.routes.url_helpers
    view.extend ActionDispatch::Routing::UrlFor

    view.build_status(status)
  end


  def self.queue_build(repo_id)
    repo   = Repo.find(repo_id) 
    build  = from_github(client(repo.user), repo_id)
    build.save
    
    repo.cancel_builds

    job_id = BuildWorker.perform_async(build[:id])
    build.update(job_id: job_id)

    Pusher.trigger(build.pusher_channel, 'new', build.render_string)
  end

  def self.from_github(client, repo_id)
    repo          = Repo.find(repo_id) 
    latest_commit = Github::Repo.last_commit(client, repo[:full_name])
    Build.new(branch: repo[:default_branch],
              repo:   repo,
              started_at: Time.now,
              commit: latest_commit.sha,
              author: latest_commit.author.login,
              message: latest_commit.commit.message,
              commit_url: latest_commit.rels[:html].href,
              status: :queued)

  end

  private
  def self.client(user)
    Octokit::Client.new(access_token: user[:auth_token])
  end

end
