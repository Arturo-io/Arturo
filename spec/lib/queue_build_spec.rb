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
      Pusher.should_receive(:trigger) 
      subject.update_status(@build)
    end

    it '.client' do
      user   = { auth_token: "auth_token" }
      client = subject.client(user)
      expect(client.access_token).to eq("auth_token")
    end

    it '.queue_build' do
      subject.stub_chain(:new, :execute).and_return true
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
        BuildWorker
          .should_receive(:perform_async)
          .with(1)
        subject.perform_async(@build)
      end

      it 'updates the builds job_id' do
        BuildWorker.stub(:perform_async).and_return 'j-123'

        @build.should_receive(:update).with(job_id: 'j-123')
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
        Github::Repo
          .should_receive(:commit)
          .with(anything, "some_repo", "sha")

        @instance.stub(:sha).and_return "sha"
        @instance.commit
      end

      it 'returns the last_commit on a repo' do
        Github::Repo
          .should_receive(:last_commit)
          .with(anything, "some_repo")

        @instance.stub(:sha).and_return nil
        @instance.commit
      end
    end

    context '#cancel_previous_builds' do
      it 'cancels previous builds for this builds repo' do
        repo = double("repo")
        repo.should_receive(:cancel_builds)
        @instance.stub(:repo).and_return(repo)
        @instance.cancel_previous_builds
      end
    end

    context '#execute' do
      before do
        @double = double("build")
        subject.stub(:assign_and_update)
        subject.stub(:perform_async)
        subject.stub(:update_status)
        @instance.stub(:cancel_previous_builds)
        @instance.stub(:create_build_from_github)
         .and_return(@double)
      end

      it 'calls assign_and_update' do
        subject.should_receive(:assign_and_update).with(@double, {})
        @instance.execute
      end

      it 'calls cancel_previous_builds' do
        @instance.should_receive(:cancel_previous_builds)
        @instance.execute
      end

      it 'calls perform_async' do
        subject.should_receive(:perform_async).with(@double)
        @instance.execute
      end

      it 'calls update_status' do
        subject.should_receive(:update_status).with(@double)
        @instance.execute
      end

    end

  end
end
