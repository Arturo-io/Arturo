require 'spec_helper'

describe Github::Status do
  before do
    @client = double("Octokit::Client") 
  end

  it 'can update a status for a ref' do
    expect(@client).to receive(:create_status) do |repo, sha, state, options|
      expect(repo).to eq("ortuna/some_repo")
      expect(sha).to eq("some_sha")
      expect(state).to eq("pending")
      expect(options[:description]).to eq("pending")
    end

    Github::Status.create(@client,     "ortuna/some_repo", 
                          "some_sha",  "pending",
                          description: "pending") 
  end
end
