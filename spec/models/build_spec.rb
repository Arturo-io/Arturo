require 'spec_helper'

describe Build do
  it 'has the correct sort order' do
    user   = create_user(login: "ortuna")
    repo   = Repo.new(full_name: "test_repo")
    (1..5).to_a.each do |i| 
      Build.create(user: user, repo: repo).update(created_at: Time.now+i.minutes)
    end

    expect(Build.first[:created_at]).to be > Build.last[:created_at]
  end


  it 'requires a repo' do
    build = Build.new
    expect(build.errors[:repo_id]).not_to be_nil
  end
  
  context 'relationships' do
    before do
      user   = create_user(login: "ortuna")
      repo   = Repo.new(full_name: "test_repo")
      @build = Build.new(user: user, repo: repo)
    end

    it 'has the repo relationship' do
      expect(@build.repo[:full_name]).to eq("test_repo")
    end

    it 'has the user relationship' do
      expect(@build.user[:login]).to eq("ortuna")
    end


  end

end
