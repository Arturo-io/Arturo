class HookController < ApplicationController
  def github
    repo_id = params[:repository][:id]

    Build.queue_build(repo_id)
    render nothing: true
  end
end
