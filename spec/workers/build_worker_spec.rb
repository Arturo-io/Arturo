require 'spec_helper'

describe BuildWorker do 
  before do
    user = create_user(auth_token: 'abc1234')
    Repo.create(id: 9, user: user, full_name: "progit-bana")
  end

  it 'ques up a job' do
    BuildWorker.perform_async(99)
    expect(BuildWorker).to have(1).job
  end

  it 'creates and calls execute on a new Generate::Build' do
    double = double("Generate::Build")
    double.stub(:execute)
    Generate::Build.should_receive(:new) do |repo_id, formats|
      expect(formats).to eq([:pdf, :epub, :mobi])
      expect(repo_id).to eq(9)
      double
    end

    BuildWorker.new.perform(9)
  end

  it 'creates a build to be used' do
    Generate::Build.stub_chain(:new, :execute)
    BuildWorker.new.perform(9)

    expect(Build.where(repo_id: 9).count).to eq(1)
  end

  it 'informas pusher about the start of a build'
  it 'informas pusher about the end of a build'
end
