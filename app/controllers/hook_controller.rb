class HookController < ApplicationController
  def github
    repo_id   = params[:repository][:id]
    following = Follower.where(repo_id: repo_id).present?

    following ? Build.queue_build(repo_id) : nil
    render nothing: true
  end
end
