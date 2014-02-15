class BuildController < ApplicationController

  #TODO: Security

  def index
    @builds  = user_builds.page(params[:page]).per(25)
    @partial = resolve_partial(@builds)
  end

  private
  def resolve_partial(builds)
    builds.empty? ? 'no_builds' : 'build_list' 
  end

  def user_builds(user_id = current_user[:id])
    Build.includes(:repo).where("repos.user_id" => user_id)
  end
end
