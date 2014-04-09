require 'spec_helper'

describe BuildStatus do
  before do
    allow(Pusher).to receive(:trigger)

    user    = create_user(id: 42, login: "ortuna")
    repo    = create_repo(id: 55, user: user, full_name: "test_repo")
    @build  = Build.new(id: 99, repo: repo, 
                        commit: "1234abc", status: :success)
    @status = BuildStatus.new(@build)
    allow(@status).to receive(:update_github)
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
    expect(Github::Status).to receive(:create) do |_client, repo, sha, state, options|
      expect(repo).to eq("test_repo")
      expect(sha).to eq("1234abc")
      expect(state.to_s).to eq("pending")
      expect(options[:description]).to eq("pending build")
    end 
    allow(@status).to receive(:update_github).and_call_original
    @status.update_github(:pending, "pending build")
  end

  it 'updates the builds status' do
    @status.update(:success)
    expect(Build.find(99)[:status]).to eq("success")
  end

  it 'updates the error message' do
    @status.update(:success, 'some error message')
    expect(Build.find(99)[:error]).to eq('some error message')
  end

  it 'updates with a message' do
    expect(@status).to receive(:update_github).with("failed", "Invalid Build")
    expect(@status).to receive(:update_pusher).with("failed", "Invalid Build")

    @status.update(:failed, "Invalid Build") 
  end

  it 'sends pusher updates' do
    expect(Pusher).to receive(:trigger) do |channel, trigger, data|
      expect(channel).to eq("#{User.find(42).digest}-builds") 
      expect(trigger).to eq("status_update") 
      expect(data[:id]).to eq(99) 
      expect(data[:status]).to match(/success/) 
      expect(data[:css_class]).to match(/success/) 
      expect(data[:description]).to eq('success build')
      expect(data[:repo_id]).to eq(55)
    end

    @status.update_pusher(:success, 'success build')
  end

  it 'sends pusher updates to repo specific channel' do
    expect(Pusher).to receive(:trigger)
                       .with("#{User.find(42).digest}-builds-55", anything, anything)
    @status.update_pusher(:success, 'success build')
  end

  it 'calls update for pusher and github' do
    expect(@status).to receive(:update_github).with("success", nil)
    expect(@status).to receive(:update_pusher).with("success", nil)

    @status.update(:success)
  end

  it 'should not call update_github if there is no commit sha' do
    expect(@status).not_to receive(:update_github).with("success")
    expect(@status).to     receive(:update_pusher).with("success", nil)
    @build.update(commit: nil)

    @status.update(:success)
  end

end
