class HookController < ApplicationController
  def github
    repo_id     = params[:repository][:id]
    head_commit = params[:head_commit][:id]
    following = Follower.where(repo_id: repo_id).present?

    following ? Build.queue_build(repo_id, head_commit) : nil
    render nothing: true
  end
end
