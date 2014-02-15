require 'spec_helper'

describe Repo do
  it 'requires a user relationship' do
    repo = Repo.new(id: 1)
    expect(repo.valid?).to eq(false)
    expect(repo.errors[:user_id]).not_to be_nil
  end
  
  it 'has the user relationship' do
    user = User.new(name: "example")
    repo = Repo.new(user: user)

    expect(repo.user[:name]).to eq("example")
  end

  it 'has the followers relationship' do
    expect(Repo.new.followers.count).to eq(0)
  end

  it 'has the builds relationship' do
    expect(Repo.new.builds.count).to eq(0)
  end
end
