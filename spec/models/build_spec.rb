require 'spec_helper'

describe Build do
  before { Pusher.stub(:trigger) }

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
        Github::Repo.should_receive(:last_commit) do |client, repo_name|
          expect(repo_name).to eq("test_repo")
          author = OpenStruct.new(login: "ortuna")
          commit = OpenStruct.new(message: "a commit message")
          rels   = { html: OpenStruct.new(href: 'http://example.com') }

          OpenStruct.new(sha: "abc123", author: author, commit: commit, rels: rels)
        end

        build = Build.from_github(double('Octokit::Client'), 99)

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
        expect { Build.queue_build(99) }.to change { Build.count }.by(1)
      end

      it 'queues a build' do
        BuildWorker.should_receive(:perform_async)
        Build.queue_build(99)
      end

      it 'triggers a pusher update' do
        Pusher.should_receive(:trigger) do |channel, trigger, rendered_string|
          expect(channel).to eq("#{User.find(42).digest}-builds")
          expect(trigger).to eq("new")
          expect(rendered_string).to match(/some commit/)
          expect(rendered_string).to match(/some author/)
          expect(rendered_string).to match(/#100/)
        end

        Build.queue_build(99)
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

  context '#update_status' do
    before do
      user   = create_user(id: 42, login: "ortuna")
      repo   = Repo.new(full_name: "test_repo")
      @build = Build.new(id: 99, user: user, repo: repo)
    end

    it 'updates the builds status' do
      Pusher.stub(:trigger)
      @build.update_status(:completed)
      expect(Build.find(99)).not_to be_nil
    end

    it 'sends pusher updates' do
      Pusher.should_receive(:trigger) do |channel, trigger, data|
        expect(channel).to eq("#{User.find(42).digest}-builds") 
        expect(trigger).to eq("status_update") 
        expect(data[:id]).to eq(99) 
        expect(data[:status]).to eq(:completed) 
      end
      @build.update_status(:completed)
    end

  end
end
