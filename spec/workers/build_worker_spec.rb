require 'spec_helper'

describe BuildWorker do 
  before do
    user = create_user(auth_token: 'abc1234')
    repo = Repo.create(user: user, full_name: "progit-bana")
    Build.create(id: 9, repo: repo)
  end

  it 'queues up a job' do
    BuildWorker.perform_async(99)
    expect(BuildWorker).to have(1).job
  end

  it 'creates and calls execute on a new Generate::Build' do
    double = double("Generate::Build")
    double.stub(:execute)
    Generate::Build.should_receive(:new) do |build_id, formats|
      expect(formats).to eq([:pdf, :epub, :mobi])
      expect(build_id).to eq(9)
      double
    end

    BuildWorker.new.perform(9)
  end

  it 'updates the build to be started' do
    build = double("Build").as_null_object
    Build.stub(:find).and_return(build)

    build.should_receive(:update).with(status: :building)
    Generate::Build.stub_chain(:new, :execute)
    BuildWorker.new.perform(9)
  end

  it 'updates the build to be started' do
    build = double("Build").as_null_object
    Build.stub(:find).and_return(build)

    build.should_receive(:update).with(status: :completed)
    Generate::Build.stub_chain(:new, :execute)
    BuildWorker.new.perform(9)
  end

  it 'informs pusher about the start of a build'
  it 'informs pusher about the end of a build'
end
