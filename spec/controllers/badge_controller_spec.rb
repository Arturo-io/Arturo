require 'spec_helper'

describe BadgeController do
  context '#show' do
    before do
      user  = create_user()
      repo  = Repo.create(id: 1, user: user)
      Build.create(repo: repo, branch: :master)
    end

    it 'redirects you to the badge url' do
      RepoBadge.any_instance.stub(:url).and_return "http://www.example.com"
      get :show, repo_id: 1, branch: :master
      assert_redirected_to "http://www.example.com"
    end

  end
end
