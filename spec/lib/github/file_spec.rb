require 'spec_helper'

describe Github::File do
  let(:subject) { Github::File }

  it 'can retreive a file form github' do
    client = double("Github::Octkit")

    client.stub(:contents) do |repo, options|
      expect(repo).to eq("ortuna/progit-bana")
      expect(options[:path]).to eq("readme.md")
      OpenStruct.new(content: "cmVhZG1lIQ==")
    end

    content = subject.fetch("ortuna/progit-bana", "readme.md", client) 
    expect(content).to eq("readme!")
  end
end
