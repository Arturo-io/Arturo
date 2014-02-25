require 'spec_helper'

describe Build do
  before do 
    Build.any_instance.stub(:render_string)
    Pusher.stub(:trigger)
    BuildStatus.any_instance.stub(:update_github)
    BuildStatus.any_instance.stub(:update_pusher)
  end

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

  context 'queue' do
    before do
      user = create_user(id: 42, login: "ortuna")
      Repo.create(user: user, 
                  id: 99, 
                  full_name: "test_repo",
                  default_branch: "master")
    end

    context '.from_github' do
      it 'instantiates a build from latest github commit' do
        Github::Repo.should_receive(:commit) do |client, repo_name|
          expect(repo_name).to eq("test_repo")
          author = OpenStruct.new(login: "ortuna")
          commit = OpenStruct.new(message: "a commit message")
          rels   = { html: OpenStruct.new(href: 'http://example.com') }

          OpenStruct.new(sha: "abc123", author: author, commit: commit, rels: rels)
        end

        build = Build.from_github(double('Octokit::Client'), 99, 'sha99')

        expect(build.commit).to  eq("abc123")
        expect(build.author).to  eq("ortuna")
        expect(build.branch).to  eq("master")
        expect(build.message).to eq("a commit message")
        expect(build.commit_url).to eq("http://example.com")
        expect(build.status).to  eq(:queued)
      end
    end

    context '.queue_build' do
      before do
        build = Build.new(repo_id: 99, 
                          id: 100,
                          started_at: Time.now,
                          commit: "some commit",
                          author: "some author",
                          message: "some message",
                          commit_url: "http://example.com",
                          status: :queued)

        Build.stub(:from_github).and_return(build)
      end

      it 'creates a build' do
        expect { Build.queue_build(99, 'sha123') }.to change { Build.count }.by(1)
      end

      it 'queues a build' do
        BuildWorker.should_receive(:perform_async)
        Build.queue_build(99, 'sha123')
      end

      it 'tracks the job_id' do 
        Build.queue_build(99, 'sha123')
        expect(Build.find(100)[:job_id]).not_to be_nil
      end

      it 'stops other builds that are already running' do
        Repo.any_instance.should_receive(:cancel_builds).once
        Build.queue_build(99, 'sha123')
      end

      it 'triggers a pusher update' do
        Repo.any_instance.stub(:cancel_builds)

        Pusher.should_receive(:trigger) do |channel, trigger, rendered_string|
          expect(channel).to eq("#{User.find(42).digest}-builds")
          expect(trigger).to eq("new")
        end

        Build.queue_build(99, 'sha123')
      end
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

end
