class RepositoryController < ApplicationController
  protect_from_forgery with: :exception

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
    @partial   = @repositories.empty? ? 'no_repos' : 'repo_list'
    @sync_icon = current_user[:loading_repos] ?  'spinner spin' : 'github-alt'
    @last_updated = Time.now
  end
end
