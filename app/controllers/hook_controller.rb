class HookController < ApplicationController
  def github
    repo_id = params[:repository][:id]
    sha     = params[:head_commit][:id]
    branch  = params[:ref] && params[:ref].split('/').last

    following = Follower.where(repo_id: repo_id).present?

    following ? queue(repo_id, sha: sha, branch: branch): nil
    render nothing: true
  end


  private
  def queue(repo_id, options = {})
    options =  options.delete_if { |k, v| v.nil? }
    QueueBuild.queue_build(repo_id, options)
  end
end
