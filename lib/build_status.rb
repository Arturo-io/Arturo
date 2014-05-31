class BuildStatus
  attr_reader :client, :build

  def initialize(build)
    @build  = build
    @client = github_client(build.user)
  end

  def update_github(status, description = nil)
    full_name = build.repo[:full_name]
    commit    = build.commit
    status    = translate_for_github(status)
    options   = { target_url: action_view.build_url(build, host: 'arturo.io') }

    options[:description] = description if description

    Github::Status.create(@client, full_name, commit, status, options)
  end

  def update_pusher(status, description = nil)
    data = { id: build.id, 
             css_class: build.status, 
             status: status_html(status),
             description: description,
             repo_id: build[:repo_id] }
    pusher_channels.each do |pusher_channel|
      Pusher.trigger(pusher_channel, 'status_update', data)
    end
  end

  def update(status, description = nil)
    status = status.to_s

    attributes = { status: status }
    attributes[:error] = description if description
    build.update(attributes) 

    update_github(status, description) if build[:commit]
    update_pusher(status, description)
  end

  def translate_for_github(status)
    status = status.to_s
    return status if %w(error failure pending success).include?(status)
    return "pending" if %w(queued created).include?(status)
    return "success" if status == "completed"
    return "failure" if status == "canceled"
    return "pending" if status.match(/building/)|| status.match(/uploading/)
    "error"
  end

  def new_pusher_channel
    build.user.digest << "-builds"
  end

  def render_string
    action_view.render(partial: 'builds/build_list_single', locals: { build: build })
  end

  private
  def pusher_channels
    [new_pusher_channel,
     build.user.digest << "-builds-#{build[:repo_id]}"]
  end

  def status_html(status)
    action_view.build_status(status)
  end

  def action_view
    view = ActionView::Base.new(Rails.configuration.paths["app/views"])
    view.extend BuildHelper
    view.extend FontAwesome::Rails::IconHelper
    view.extend ActionView::Helpers
    view.extend Rails.application.routes.url_helpers
    view.extend ActionDispatch::Routing::UrlFor
    view.class_eval do
      def default_url_options; {} end
    end
    view
  end
  
  def github_client(user)
    Octokit::Client.new(access_token: user[:auth_token])
  end

end
