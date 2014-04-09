require 'spec_helper'

describe RepoSyncWorker do
  before do
    create_user(id: 42)
    allow(Pusher).to receive(:trigger)
  end

  it 'calls sync on Github::Repo' do
    expect(Github::Repo).to receive(:sync).with(42)
    RepoSyncWorker.new.perform(42)
  end

  it 'queues the job' do
    RepoSyncWorker.perform_async(42)
    expect(RepoSyncWorker).to have(1).job
  end

  it 'sets last_sync_at on user to true' do
    allow(Time).to receive(:now).and_return(112233)
    expect_any_instance_of(User).to receive(:last_sync_at=).with(112233)
    allow(Github::Repo).to receive(:sync)
    RepoSyncWorker.new.perform(42)
  end

  it 'sets loading_repo on user to true' do
    expect_any_instance_of(User).to receive(:loading_repos=).with(false)
    allow(Github::Repo).to receive(:sync)
    RepoSyncWorker.new.perform(42)
  end

  it 'sends a Pusher notification' do
    user_channel = "#{User.find(42).digest}-repositories"

    expect(Pusher).to receive(:trigger) do |channel, event, message|
      expect(channel).to eq(user_channel) 
      expect(event).to eq('sync_complete')
      expect(message).to eq({completed: true})
    end

    allow(Github::Repo).to receive(:sync)
    RepoSyncWorker.new.perform(42)
  end
end
