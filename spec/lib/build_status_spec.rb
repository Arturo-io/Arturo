require 'spec_helper'

describe BuildStatus do
  before do
    Pusher.stub(:trigger)

    user    = create_user(id: 42, login: "ortuna")
    repo    = Repo.new(full_name: "test_repo")
    @build  = Build.new(id: 99, user: user, 
                        repo: repo, commit: "1234abc", 
                        status: :completed)
    @status = BuildStatus.new(@build)
    @status.stub(:update_github)
  end

  context '#initialize' do
    it 'takes in a build as its param' do
      BuildStatus.new(@build)
    end

    it 'creates the client' do
      expect(BuildStatus.new(@build).client).not_to be_nil
    end
  end

  it '#translate_for_github' do
    expect(@status.translate_for_github(:queued)).to eq("pending")
    expect(@status.translate_for_github(:created)).to eq("pending")
    expect(@status.translate_for_github(:error)).to eq("error")
    expect(@status.translate_for_github(:failure)).to eq("failure")
    expect(@status.translate_for_github(:pending)).to eq("pending")
    expect(@status.translate_for_github(:completed)).to eq("success")
    expect(@status.translate_for_github(:canceled)).to eq("failure")

    expect(@status.translate_for_github("building PDF")).to eq("pending")
    expect(@status.translate_for_github("building Mobi")).to eq("pending")
    expect(@status.translate_for_github("uploading PDF")).to eq("pending")
    expect(@status.translate_for_github("xyz")).to eq("error")
  end

  it '#update_github updates the github sha' do
    Github::Status.should_receive(:create) do |_client, repo, sha, state, options|
      expect(repo).to eq("test_repo")
      expect(sha).to eq("1234abc")
      expect(state.to_s).to eq("pending")
    end 
    @status.unstub(:update_github)
    @status.update_github(:pending)
  end

  it 'updates the builds status' do
    @status.update(:completed)
    expect(Build.find(99)).not_to be_nil
  end

  it 'sends pusher updates' do
    Pusher.should_receive(:trigger) do |channel, trigger, data|
      expect(channel).to eq("#{User.find(42).digest}-builds") 
      expect(trigger).to eq("status_update") 
      expect(data[:id]).to eq(99) 
      expect(data[:status]).to match(/completed/) 
      expect(data[:css_class]).to match(/completed/) 
    end
    @status.update_pusher(:completed)
  end

  it 'calls update for pusher and github' do
    @status.should_receive(:update_github).with("completed")
    @status.should_receive(:update_pusher).with("completed")

    @status.update(:completed)
  end

  it 'should not call update_github if there is no commit sha' do
    @status.should_not_receive(:update_github).with("completed")
    @status.should_receive(:update_pusher).with("completed")
    @build.update(commit: nil)

    @status.update(:completed)
  end

end
