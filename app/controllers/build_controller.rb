class BuildController < ApplicationController

  def index
    @builds  = user_builds.page(params[:page]).per(25)
    @partial = @builds.empty? ? 'no_builds' : 'build_list' 
  end

  private
  def user_builds(user_id = current_user[:id])
    Build.includes(:repo).where("repos.user_id" => user_id)
  end
end
