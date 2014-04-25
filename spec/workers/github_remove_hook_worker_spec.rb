require 'spec_helper'

describe GithubRemoveHookWorker do
  before do
    create_user(id: 42)
    Repo.create(user_id: 42, id: 99, hook_id: nil)
  end

  it 'queues the job' do
    allow(Github::Hook).to receive(:create_hook).and_return({id: 000})

    GithubRemoveHookWorker.perform_async(99)
    expect(GithubRemoveHookWorker).to have(1).job
  end

  it 'calls .remove_hook on Github::Hook' do
    expect(Github::Hook).to receive(:remove_hook)
    GithubRemoveHookWorker.new.perform(99) 
  end

  it 'sets the hook_id on a repo' do
    allow(Github::Hook).to receive(:remove_hook)

    GithubRemoveHookWorker.new.perform(99)
    expect(Repo.find(99)[:hook_id]).to eq(nil)
  end

end
