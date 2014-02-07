require 'spec_helper'

describe RepoSyncWorker do
  before { create_user(id: 42) }
  it 'calls sync on Github::Repo' do
    Github::Repo.should_receive(:sync).with(42)
    RepoSyncWorker.new.perform(42)
  end

  it 'queues the job' do
    RepoSyncWorker.perform_async(42)
    expect(RepoSyncWorker).to have(1).job
  end

  it 'sets last_sync_at on user to true' do
    Time.stub(:now).and_return(112233)
    User.any_instance.should_receive(:last_sync_at=).with(112233)
    Github::Repo.stub(:sync)
    RepoSyncWorker.new.perform(42)
  end

  it 'sets loading_repo on user to true' do
    User.any_instance.should_receive(:loading_repos=).with(false)
    Github::Repo.stub(:sync)
    RepoSyncWorker.new.perform(42)
  end
end
