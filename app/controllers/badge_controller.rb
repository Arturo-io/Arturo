class BadgeController < ApplicationController
  def show
    redirect_url = "http://arturo-badges.herokuapp.com/badge/"
    redirect_url = redirect_url << badge_params(params[:repo_id], :master)
    redirect_url = redirect_url << "@2x.png"
    redirect_to redirect_url
  end

  private
  def badge_params(repo_id, branch)
    build = Build.where(repo_id: repo_id).first
    build_count = (build && build.id) || 0
    "build-#{build_count}-brightgreen"
  end
end
