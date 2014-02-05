class RepositoriesController < ApplicationController
  protect_from_forgery with: :exception

  def index
    @repositories = Repo.where(user: current_user)
                        .page(params[:page]).per(25)
  end
end
