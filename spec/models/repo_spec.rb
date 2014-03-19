require 'spec_helper'

describe Repo do
  before do
    Build.any_instance.stub(:update_status_github)
    Pusher.stub(:trigger)
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
    it 'retrieves all the users repos' do
      expect { 
        10.times { Repo.create(user_id: 42, name: "some_repo") }
        10.times { Repo.create(user_id: 41, name: "some_repo") }
      }.to change { Repo.user_repositories(42).count }.from(0).to(10)
    end

    it 'sorts the followed repos at the top' do
      followed = [5, 9, 1]
      10.times do |n| 
        Repo.create(id: n, user_id: 42, name: "repo #{n}", pushed_at: Time.now + n.minutes)
      end

      followed.each { |i| Follower.create(repo_id: i, user_id: 42) }
      repos = Repo.user_repositories(42)

      (0..2).each do |i|
        expect(followed.include?(repos[i].id)).to eq(true)
      end
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
      Repo.find(1).cancel_builds
      expect(Build.find(1).status).to eq("canceled")
      expect(Build.find(2).status).to eq("canceled")
      expect(Build.find(3).status).to eq("completed")
    end

    context '.cancel_jobs_in_set' do
      it 'cancels all builds on sidekiq' do
        Repo.any_instance.should_receive(:cancel_jobs_in_set) do |ids, set|
          expect(ids).to include('xyz')
          expect(ids).to include('abc')
          expect(['schedule', 'retry']).to include(set)
        end.twice

        Repo.find(1).cancel_builds
      end

      it 'calls delete on a job' do
        job_double = double('Sidekiq::Job')
        job_double.stub(:jid).and_return('abc')
        job_double.should_receive(:delete)

        Sidekiq::SortedSet.stub(:new).and_return([job_double])

        Repo.find(1).send(:cancel_jobs_in_set, ['abc'], 'retry')
      end
    end
  end
end
