require 'spec_helper'

describe RepositoryHelper do
  let(:subject) { RepositoryHelper }

  context '#followed_org_count' do
    it 'gets the count of repos belonging to a org' do
      user = create_user
      repo  = Repo.create!(user: user, org: "github")
      repo2 = Repo.create!(user: user, org: "github")
      repo3 = Repo.create!(user: user, org: "other")

      Follower.create(user: user, repo: repo)
      Follower.create(user: user, repo: repo2)
      Follower.create(user: user, repo: repo3)

      expect(followed_org_count(user, "github")).to eq(2)
      expect(followed_org_count(user, "other")).to eq(1)
    end
  end
end

 
