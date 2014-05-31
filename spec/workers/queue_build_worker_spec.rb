require 'spec_helper'

describe QueueBuildWorker do
  before do
    Repo.create(user_id: 42, id: 99, hook_id: nil)
  end

  it 'queues the job' do
    QueueBuildWorker.perform_async(99)
    expect(QueueBuildWorker).to have(1).job
  end

  it 'calls execute on QueueBuild' do
    expect(QueueBuild).to receive(:queue_build).with(99)
    QueueBuildWorker.new.perform(99)
  end

end
