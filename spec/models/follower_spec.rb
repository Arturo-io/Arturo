require 'spec_helper'

describe Follower do
  context '.with_user' do
    it 'returns only the followed repos for a user' do
      user    = create_user
      repos   = 3.times.map { Repo.create!(user: user, org: "github") }
      _other  = 3.times.map { Repo.create!(user: user, org: "other") }
      _uother = 3.times.map { Repo.create!(user_id: 2, org: "other_user") }


      expect(Follower.with_user(user).count).to eq(0)

      Follower.create!(repo: repos[0], user_id: 1)
      expect(Follower.with_user(user).count).to eq(1)
    end
  end

end

