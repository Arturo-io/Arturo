require 'spec_helper'

describe Repo do
  before do
    allow_any_instance_of(Build).to receive(:update_status_github)
    allow(Pusher).to receive(:trigger)
  end

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

  context '.user_repositories' do
    before do
      create_user(id: 42, login: "ortuna")
      10.times do |n|
        Repo.create(id: n, user_id: 42, name: "repo #{n}", pushed_at: Time.now + n.minutes, org: "ortuna")
        Repo.create(id: n+10, user_id: 42, name: "repo #{n}", org: "some_org")
        Repo.create(id: n+20, user_id: 41, name: "repo #{n}")
      end
    end

    it 'retrieves all the users repos' do
      expect(Repo.user_repositories(42, "ortuna").count).to eq(10)
    end

    it 'sorts the followed repos at the top' do
      followed = [5, 9, 1]
      followed.each { |i| Follower.create(repo_id: i, user_id: 42) }
      repos = Repo.user_repositories(42, "ortuna")

      (0..2).each do |i|
        expect(followed.include?(repos[i].id)).to eq(true)
      end
    end

    it 'only gets the current users orgs' do
      repos = Repo.user_repositories(42, "sOme_org")
      expect(repos.first.org).to eq("some_org")
    end
  end

  context '.user_orgs' do
    it 'fetches the distinct users orgs from repos' do
      create_user(id: 42, login: "User")

      Repo.create(id: 1, user_id: 42, name: "repo 1", org: "org1")
      Repo.create(id: 2, user_id: 42, name: "repo 2", org: "org2")
      Repo.create(id: 3, user_id: 42, name: "repo 3", org: "org3")
      Repo.create(id: 4, user_id: 42, name: "repo 1", org: "user")

      expect(Repo.user_orgs(42)).to eq(["user", "org1", "org2", "org3"]) 
    end
  end

  context '#cancel_builds' do
    before do
      user = create_user(id: 42)
      repo = Repo.create(id: 1, user: user, full_name: "some_repo")
      Build.create(id: 1, repo: repo, status: :queued, job_id: 'abc')
      Build.create(id: 2, repo: repo, status: :queued, job_id: 'xyz')
      Build.create(id: 3, repo: repo, status: :completed, job_id: 'xxx')
    end

    it 'updates the status on all builds to canceled' do
      repo = Repo.find(1)
      expect(repo).to receive(:cancel_jobs)

      repo.cancel_builds

      expect(Build.find(1).status).to eq("canceled")
      expect(Build.find(2).status).to eq("canceled")
      expect(Build.find(3).status).to eq("completed")
    end

    context '.cancel_jobs_in_set' do
      it 'cancels all builds on sidekiq' do
        expect_any_instance_of(Repo).to receive(:cancel_jobs_in_set) do |ids, set|
          expect(ids).to include('xyz')
          expect(ids).to include('abc')
          expect(['schedule', 'retry']).to include(set)
        end.twice

        Repo.find(1).cancel_builds
      end

      it 'calls delete on a job' do
        job_double = double('Sidekiq::Job')
        allow(job_double).to receive(:jid).and_return('abc')
        expect(job_double).to receive(:delete)

        expect(Sidekiq::SortedSet).to receive(:new).and_return([job_double])

        Repo.find(1).send(:cancel_jobs_in_set, ['abc'], 'retry')
      end
    end
  end
end
