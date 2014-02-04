class RepositoriesController < ApplicationController
  protect_from_forgery with: :exception

  def index
    @repositories = Repo.all
    render json: @repositories
  end
end
