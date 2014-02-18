require 'spec_helper'

describe HookController do
  context '#github' do
    it 'creates a build' do
      user = create_user(login: "user")
      _repo = Repo.create(id: 1, user: user)

      Build.should_receive(:queue_build).with("1")
      get :github,  repository: { id: 1 }
    end
  end
end
