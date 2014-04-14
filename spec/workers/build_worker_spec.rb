require 'spec_helper'

describe BuildWorker do 
  before do
    user = create_user(id: 42, auth_token: 'abc1234')
    repo = Repo.create(user: user, full_name: "progit-bana")
    Build.create(id: 9, repo: repo)

    allow(Pusher).to receive(:trigger)
  end

  it 'queues up a job' do
    BuildWorker.perform_async(99)
    expect(BuildWorker).to have(1).job
  end

  context 'with fake double' do
    before do
      @double = double("Generate::Build").as_null_object
      allow(@double).to receive(:execute).and_return([])

      allow(Generate::Book).to receive_message_chain(:new, :execute).and_return([])
      allow(Build).to receive(:find).and_return(@double)

      allow(Generate::Build::Diff).to receive_message_chain(:new, :execute)
        .and_return('http://www.google.com')
    end

    it 'creates and calls execute on a new Generate::Build' do
      expect(Generate::Book).to receive(:new) do |build_id, formats|
        expect(formats).to eq([:pdf, :html, :epub, :mobi])
        expect(build_id).to eq(9)
        @double
      end

      BuildWorker.new.perform(9)
    end

    it 'creates an asset for the URLs' do
      assets = [ 'http://reddit.com' , 'http://google.com']
      expect(Generate::Book).to receive_message_chain(:new, :execute)
        .and_return(assets)

      expect(Asset).to receive(:create)
        .twice
        .and_return(nil)
      BuildWorker.new.perform(9)
    end

    it 'calls #update_status on the build' do
      expect(@double).to receive(:update_status).with(:building)
      expect(@double).to receive(:update_status).with(:success)
      BuildWorker.new.perform(9)
    end

    it 'creates a diff' do
      expect(::BuildDiff).to receive(:create).with(build_id: 9, url: 'http://www.google.com')

      BuildWorker.new.perform(9)
    end

  end

end
