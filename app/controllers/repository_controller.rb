class RepositoryController < ApplicationController
  protect_from_forgery with: :exception

  before_filter :check_login
  authority_actions follow: :read, unfollow: :read, sync: :read
  authorize_actions_for ApplicationAuthorizer

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
    @repositories = Repo.where(user: current_user)
                        .page(params[:page]).per(25)
    @last_updated = current_user[:last_sync_at]

    @partial      = @repositories.empty? ? 'no_repos' : 'repo_list'
    @sync_icon    = current_user[:loading_repos] ?  'spinner spin' : 'github-alt'

    @following    = Follower.where(user: current_user).map(&:repo_id)
    @pusher_channel = current_user.digest
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
    Follower.where(user: current_user, repo: repo).first.destroy
    GithubRemoveHookWorker.perform_async(repo[:id])
    redirect_to repositories_path, notice: "You are no longer following #{repo.name}"
  end
end
