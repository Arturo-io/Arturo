require 'spec_helper'

describe RepoSyncWorker do
  it 'calls sync on Github::Repo' do
    Github::Repo.should_receive(:sync).with(42)
    RepoSyncWorker.new.perform(42)
  end

  it 'queues the job' do
    RepoSyncWorker.perform_async(42)
    expect(RepoSyncWorker).to have(1).job
  end
end
