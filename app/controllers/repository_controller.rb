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
    @last_updated = Time.now

    @partial      = @repositories.empty? ? 'no_repos' : 'repo_list'
    @sync_icon    = current_user[:loading_repos] ?  'spinner spin' : 'github-alt'

    @following    = Follower.where(user: current_user).map(&:repo_id)
  end

  def follow
    authorize_action_for(Repo.find(params[:id]))

    Follower.create(user: current_user, repo_id: params[:id])
    redirect_to repositories_path
  end

  def unfollow
    Follower.where(user: current_user, repo_id: params[:id]).first.destroy
    redirect_to repositories_path
  end
end
