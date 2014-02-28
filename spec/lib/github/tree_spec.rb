require 'spec_helper'
describe Github::Tree do

  context 'fetch' do 
    it 'can fetch a tree from a repo' do
      client = double("Octokit::Client")
      client.should_receive(:tree) do |repo, sha|
        expect(repo).to eq("ortuna/progit-bana")
        expect(sha).to  eq("sha1234")
        [{tree: true}]
      end

      tree = Github::Tree.fetch(client, "ortuna/progit-bana", "sha1234") 
      expect(tree).to eq([{tree: true}])
    end
  end
end
