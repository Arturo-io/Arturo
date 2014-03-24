class RepositoryController < ApplicationController
  protect_from_forgery with: :exception
  before_filter :check_login, except: [:show]

  authorize_actions_for RepoAuthorizer
  authority_actions follow:   'update', 
                    unfollow: 'update', 
                    build:    'update',
                    sync:     'read'

  def sync
    if(current_user[:loading_repos])
      redirect_to repositories_path, alert: 'Sync already in progress'
    else
      current_user.update(loading_repos: true)
      RepoSyncWorker.perform_async(session[:user_id])
      redirect_to repositories_path
    end
  end

  def index
    @last_updated   = current_user[:last_sync_at]
    @following      = Follower.where(user: current_user).map(&:repo_id)
    @org            = params[:org] || current_user[:login]
    @repositories   = user_repositories(current_user[:id], @org)
    @orgs           = Repo.user_orgs(current_user[:id])
    @partial        = @repositories.empty? ? 'no_repos' : 'repo_list'
    @sync_icon      = current_user[:loading_repos] ?  'spinner spin' : 'github-alt'
    @pusher_channel = "#{current_user.digest}-repositories"
  end

  def show
    @repo           = Repo.includes(:builds).find(params[:id])
    @builds         = @repo.builds.page(params[:page]).per(5)
    @badge_markdown = badge_markdown(@repo[:id])
    @last_build     = Build.where(repo: @repo, status: :success).first
    @last_assets    = @last_build && @last_build.assets
    @pusher_channel = "#{current_user.digest}-builds-#{@repo[:id]}"

    authorize_action_for @repo
  end

  def follow
    repo = Repo.find(params[:id])
    authorize_action_for repo

    Follower.create(user: current_user, repo: repo)
    GithubCreateHookWorker.perform_async(repo[:id])
    redirect_to repositories_path, notice: "You are now following #{repo.name}"
  end

  def unfollow
    repo = Repo.find(params[:id])
    authorize_action_for repo

    Follower.where(user: current_user, repo: repo).first.destroy
    GithubRemoveHookWorker.perform_async(repo[:id])
    redirect_to repositories_path, notice: "You are no longer following #{repo.name}"
  end

  def build
    repo = Repo.find(params[:id])
    authorize_action_for repo

    QueueBuild.queue_build(repo[:id])
    redirect_to repositories_show_path(repo[:id]), notice: "A build has been queued for #{repo.name}"
  end

  private
  def user_repositories(user_id, org)
     Repo.user_repositories(user_id, org).page(params[:page]).per(25)
  end

  def badge_markdown(repo_id)
    badge_url = badge_url(repo_id: repo_id, only_path: false)
    repo_url  = repositories_show_url(id: repo_id)
    "[![Build Status](#{badge_url})](#{repo_url})"
  end
end
