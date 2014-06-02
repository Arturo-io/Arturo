class HooksController < ApplicationController
  def github
    render(nothing: true) and return if params[:zen].present?
    repo_id = params[:repository][:id]
    sha     = params[:head_commit][:id]
    branch  = params[:ref] && params[:ref].split('/').last
    before  = params[:before]
    after   = params[:after]

    following = Follower.where(repo_id: repo_id).present?

    following ? queue(repo_id, sha: sha, branch: branch, before: before, after: after): nil
    render nothing: true
  end


  private
  def queue(repo_id, options = {})
    options =  options.delete_if { |k, v| v.nil? }
    QueueBuild.queue_build(repo_id, options)
  end
end
