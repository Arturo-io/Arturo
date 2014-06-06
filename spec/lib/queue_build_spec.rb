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
      expect(Pusher).to receive(:trigger).twice
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
        instance = subject.new(2, before: '123', after: 'abc')

        expect(BuildWorker).to receive(:perform_async).with(1)
        instance.send(:queue_worker, @build)
      end

      it 'updates the builds job_id' do
        allow(BuildWorker).to receive(:perform_async).and_return 'j-123'

        instance = subject.new(2, before: '123', after: 'abc')
        expect(@build).to receive(:update).with(job_id: 'j-123')
        instance.send(:queue_worker, @build)
      end
    end


  end

  context 'instance' do
    before do
      @instance = subject.new(2, before: '123', after: 'abc')
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

    context '#author' do
      it 'returns an author struct' do
        commit = {author: nil}
        output = @instance.author(commit)
        expect(output[:author]).to eq('N/A')
        expect(output[:author_url]).to eq('')
        expect(output[:author_avatar]).to eq('')
      end
    end

    context '#execute' do
      before do
        @double = double("build")
        allow(subject).to receive(:assign_and_update)
        allow(subject).to receive(:perform_async)
        allow(subject).to receive(:update_status)

        allow(@instance).to receive(:cancel_previous_builds)
        allow(@instance).to receive(:queue_worker)
        allow(@instance).to receive(:create_build_from_github).and_return(@double)
      end

      it 'sends the right author' do
        fake_author = {author: 'some_author',
                       author_url: 'some_url',
                       author_avatar: 'some_url'}

        commit = double().as_null_object
        allow(@instance).to receive(:create_build_from_github).and_call_original
        allow(@instance).to receive(:author).and_return(fake_author)
        allow(@instance).to receive(:commit).and_return(commit)

        expect(Build).to receive(:new).with(anything) do |options|
          expect(options[:author]).to eq('some_author')
          expect(options[:author_url]).to eq('some_url')
          expect(options[:author_avatar]).to eq('some_url')
        end

        @instance.execute
      end

      it 'calls assign_and_update' do
        expect(subject).to receive(:assign_and_update)
          .with(@double, before: '123', after: 'abc')
        @instance.execute
      end

      it 'calls cancel_previous_builds' do
        expect(@instance).to receive(:cancel_previous_builds)
        @instance.execute
      end

      it 'calls queue_worker' do
        expect(@instance).to receive(:queue_worker).with(@double)
        @instance.execute
      end

      it 'calls update_status' do
        expect(subject).to receive(:update_status).with(@double)
        @instance.execute
      end
    end

  end
end
