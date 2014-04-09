require 'spec_helper'

describe QueueBuild do
  subject { QueueBuild }

  before do 
    @user  = create_user(id: 42)
    @repo  = create_repo(id: 2, user: @user, full_name: "some_repo")
    @build = create_build(id: 1, repo: @repo) 
  end

  context 'utility methods' do
    it '.update_status' do
      allow(Pusher).to receive(:trigger) 
      subject.update_status(@build)
    end

    it '.client' do
      user   = { auth_token: "auth_token" }
      client = subject.client(user)
      expect(client.access_token).to eq("auth_token")
    end

    it '.queue_build' do
      allow(subject).to receive_message_chain(:new, :execute).and_return true
      expect(subject.queue_build).to eq(true)
    end

    it '.assign_and_update' do
      options = { author: "some_new_author", commit: "abc" }
      subject.assign_and_update(@build, options)

      build = Build.find(1)
      expect(build.author).to eq("some_new_author")
      expect(build.commit).to eq("abc")
    end

    context '.perform_async' do
      it 'does a perform_async for BuildWorker' do
        expect(BuildWorker).to receive(:perform_async).with(1)
        subject.perform_async(@build)
      end

      it 'updates the builds job_id' do
        allow(BuildWorker).to receive(:perform_async).and_return 'j-123'

        expect(@build).to receive(:update).with(job_id: 'j-123')
        subject.perform_async(@build)
      end
    end


  end

  context 'instance' do
    before do
      @instance = subject.new(2)
    end

    context '#commit' do
      it 'returns the commit for a sha' do
        expect(Github::Repo).to receive(:commit)
                                 .with(anything, "some_repo", "sha")
        allow(@instance).to receive(:sha).and_return "sha"
        @instance.commit
      end

      it 'returns the last_commit on a repo' do
        expect(Github::Repo).to receive(:last_commit).with(anything, "some_repo")
        allow(@instance).to receive(:sha).and_return nil
        @instance.commit
      end
    end

    context '#cancel_previous_builds' do
      it 'cancels previous builds for this builds repo' do
        repo = double("repo")
        expect(repo).to receive(:cancel_builds)
        allow(@instance).to receive(:repo).and_return(repo)
        @instance.cancel_previous_builds
      end
    end

    context '#execute' do
      before do
        @double = double("build")
        allow(subject).to receive(:assign_and_update)
        allow(subject).to receive(:perform_async)
        allow(subject).to receive(:update_status)

        allow(@instance).to receive(:cancel_previous_builds)
        allow(@instance).to receive(:create_build_from_github).and_return(@double)
      end

      it 'calls assign_and_update' do
        expect(subject).to receive(:assign_and_update).with(@double, {})
        @instance.execute
      end

      it 'calls cancel_previous_builds' do
        expect(@instance).to receive(:cancel_previous_builds)
        @instance.execute
      end

      it 'calls perform_async' do
        expect(subject).to receive(:perform_async).with(@double)
        @instance.execute
      end

      it 'calls update_status' do
        expect(subject).to receive(:update_status).with(@double)
        @instance.execute
      end

    end

  end
end
