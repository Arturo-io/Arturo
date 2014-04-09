require 'spec_helper'

describe Build do

  it 'has the correct sort order' do
    user   = create_user(login: "ortuna")
    repo   = Repo.new(id: 99, full_name: "test_repo")
    (1..5).to_a.each do |i| 
      Build.create(user: user, repo: repo).update(created_at: Time.now+i.minutes)
    end

    expect(Build.first[:created_at]).to be > Build.last[:created_at]
  end

  it 'requires a repo' do
    build = Build.new
    expect(build.errors[:repo_id]).not_to be_nil
  end

  context '#update_status' do
    before do 
      user   = create_user(login: "ortuna")
      @build = Build.new(user: user)
    end

    it 'creates and calls update on BuildStatus' do
      double = double("BuildStatus")
      allow(@build).to receive(:build_status).and_return(double)

      expect(double).to receive(:update).with(:created, nil)
      @build.update_status(:created)

      expect(double).to receive(:update).with(:created, "message")
      @build.update_status(:created, "message")
    end
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

  context 'scope' do
    before do
      user   = create_user(login: "ortuna")
      repo   = Repo.create(id: 5, full_name: "test_repo", user: user)
      Build.create(id: 41, repo: repo, status: :success, branch: :other) 
      Build.create(id: 42, repo: repo, status: :success, branch: :master) 
      Build.create(id: 43, repo: repo, status: :completed) 
      5.times { Build.create(repo: repo, status: :failure) } 
    end

    context '#last_successful_build' do
      it 'can find the last successful build' do
        build = Build.last_successful_build(5, :other)
        expect(build.id).to eq(41)
      end

      it 'defaults to the master branch' do
        build = Build.last_successful_build 5
        expect(build.id).to eq(42)
      end
    end
  end

end
