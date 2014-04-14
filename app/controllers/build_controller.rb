class BuildController < ApplicationController
  protect_from_forgery with: :exception

  before_filter :check_login, except: [:show]
  authorize_actions_for BuildAuthorizer, except: :index

  def index
    @builds  = user_builds.page(params[:page]).per(25)
    @partial = resolve_partial(@builds)
    @pusher_channel = "#{current_user.digest}-builds"
  end

  def show
    @build  = Build.includes(:assets, :user).find(params[:id])
    authorize_action_for @build

    @diff   = @build.build_diff
    @repo   = @build.repo
    @assets = @build.assets
  end

  private
  def resolve_partial(builds)
    builds.empty? ? 'no_builds' : 'build_list' 
  end

  def user_builds(user_id = current_user[:id])
    Build.includes(:repo).where("repos.user_id" => user_id)
  end
end
