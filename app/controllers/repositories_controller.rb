class RepositoriesController < ApplicationController
  protect_from_forgery with: :exception

  def sync
    RepoSyncWorker.perform_async(session[:user_id])
    redirect_to repositories_path
  end

  def index
    @repositories = Repo.where(user: current_user)
                        .page(params[:page]).per(25)
    @last_updated = Time.now
  end
end
