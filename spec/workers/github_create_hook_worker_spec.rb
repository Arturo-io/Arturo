require 'spec_helper'

describe GithubCreateHookWorker do
  before do
    create_user(id: 42)
    Repo.create(user_id: 42, id: 99, hook_id: nil)
  end

  it 'queues the job' do
    allow(Github::Hook).to receive(:create_hook).and_return({id: 000})

    GithubCreateHookWorker.perform_async(99)
    expect(GithubCreateHookWorker).to have(1).job
  end

  it 'calls .create_hook on Github::Hook' do
    allow(Github::Hook).to receive(:create_hook).and_return({id: 000})
    GithubCreateHookWorker.new.perform(99) 
  end

  it 'sets the hook_id on a repo' do
    expect(Github::Hook).to receive(:create_hook)
      .and_return({id: 112233})

    GithubCreateHookWorker.new.perform(99)
    expect(Repo.find(99)[:hook_id]).to eq(112233)
  end

  it 'sends a notification when hook creation fails' do
    expect(Github::Hook).to receive(:create_hook)
      .and_raise(Octokit::NotFound)

    expect(Notifier).to receive(:send_failed_hook_create)
      .with(99)

    GithubCreateHookWorker.new.perform(99)
  end

end
