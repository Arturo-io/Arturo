require 'spec_helper'

describe HooksController do
  render_views

  context '#github' do
    before do
      user             = create_user(login: "user")
      followed_repo    = Repo.create(id: 1,  user: user)
      _unfollowed_repo = Repo.create(id: 99, user: user)

      Follower.create(repo: followed_repo, user: user)
    end

    it 'creates a build with the sha' do
      expect(QueueBuild).to receive(:queue_build).with("1", {sha: "abc1234"})
      get :github,  repository: { id: 1}, head_commit: { id: 'abc1234'}
    end

    it 'sends the branch when ref is available' do
      expect(QueueBuild).to receive(:queue_build).with("1", {sha: "abc1234", branch: "nacho"})
      get :github,  ref: "ref/heads/nacho", repository: { id: 1}, head_commit: { id: 'abc1234'}
    end

    it 'only creates a build for a repo that is followed' do
      expect(QueueBuild).not_to receive(:queue_build)
      get :github,  repository: { id: 99}, head_commit: { id: 'abc1234'}
    end

    it 'sends the compare url for the commit' do
      expect(QueueBuild).to receive(:queue_build) do |_repo, options|
        expect(options[:before]).to eq('123')
        expect(options[:after]).to eq('abc')
      end

      get :github,  repository: { id: 1}, head_commit: { id: 'abc1234'}, before: '123', after: 'abc'
    end
  end
end
