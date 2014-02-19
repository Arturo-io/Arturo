require 'spec_helper'

describe HookController do
  context '#github' do
    before do
      user             = create_user(login: "user")
      followed_repo    = Repo.create(id: 1,  user: user)
      _unfollowed_repo = Repo.create(id: 99, user: user)

      Follower.create(repo: followed_repo, user: user)
    end

    it 'creates a build' do
      Build.should_receive(:queue_build).with("1")
      get :github,  repository: { id: 1 }
    end

    it 'only creates a build for a repo that is followed' do
      Build.should_not_receive(:queue_build)
      get :github,  repository: { id: 99 }
    end
  end
end
