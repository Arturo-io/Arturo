require 'spec_helper'

describe BadgeController do
  render_views

  context '#show' do
    before do
      user  = create_user()
      repo  = create_repo(id: 1, user: user)
      create_build(repo: repo, branch: :master, status: :success, ended_at: Time.now)
    end

    it 'redirects you to the badge url' do
      get :show, repo_id: 1, branch: :master
      assert_response :redirect
    end

  end
end
