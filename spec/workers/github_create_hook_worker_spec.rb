require 'spec_helper'

describe GithubCreateHookWorker do
  before do
    create_user(id: 42)
    Repo.create(user_id: 42, id: 99, hook_id: nil)
  end

  it 'queues the job' do
    Github::Hook.stub(:create_hook).and_return({id: 000})

    GithubCreateHookWorker.perform_async(99)
    expect(GithubCreateHookWorker).to have(1).job
  end

  it 'calls .create_hook on Github::Hook' do
    Github::Hook.stub(:create_hook).and_return({id: 000})
    GithubCreateHookWorker.new.perform(99) 
  end

  it 'sets the hook_id on a repo' do
    Github::Hook.should_receive(:create_hook).and_return({id: 112233})

    GithubCreateHookWorker.new.perform(99)
    expect(Repo.find(99)[:hook_id]).to eq(112233)
  end

end
