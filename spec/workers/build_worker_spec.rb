require 'spec_helper'

describe BuildWorker do 
  before do
    user = create_user(id: 42, auth_token: 'abc1234')
    repo = Repo.create(user: user, full_name: "progit-bana")
    Build.create(id: 9, repo: repo)

    Pusher.stub(:trigger)
  end

  it 'queues up a job' do
    BuildWorker.perform_async(99)
    expect(BuildWorker).to have(1).job
  end

  context 'with fake double' do
    before do
      @double = double("Generate::Build").as_null_object
      @double.stub(:execute).and_return([])

      Generate::Book.stub_chain(:new, :execute).and_return([])
      Build.stub(:find).and_return(@double)
    end

    it 'creates and calls execute on a new Generate::Build' do
      Generate::Book.should_receive(:new) do |build_id, formats|
        expect(formats).to eq([:pdf, :html, :epub, :mobi])
        expect(build_id).to eq(9)
        @double
      end

      BuildWorker.new.perform(9)
    end

    it 'creates an asset for the URLs' do
      assets = [ 'http://reddit.com' , 'http://google.com']
      Generate::Book.stub_chain(:new, :execute).and_return(assets)

      Asset.should_receive(:create).twice.and_return(nil)
      BuildWorker.new.perform(9)
    end

    it 'calls #update_status on the build' do
      @double.should_receive(:update_status).with(:building)
      @double.should_receive(:update_status).with(:success)
      BuildWorker.new.perform(9)
    end

  end

end
