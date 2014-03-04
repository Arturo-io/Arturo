class BadgeController < ApplicationController
  def show
    build = Build.last_successful_build(params[:repo_id], params[:branch])  
    redirect_to RepoBadge.new(build).url 
  end
end
