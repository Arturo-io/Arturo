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

    content = subject.fetch("ortuna/progit-bana", "readme.md", nil, client) 
    expect(content).to eq("readme!")
  end

  it 'can retreive a file from the right SHA' do
    client = double("Github::Octkit")

    client.stub(:contents) do |_, options|
      expect(options[:ref]).to eq("some_sha")
      OpenStruct.new(content: "cmVhZG1lIQ==")
    end

    content = subject.fetch("ortuna/progit-bana", "readme.md", "some_sha", client) 
    expect(content).to eq("readme!")
  end

  it 'forces the UTF-8' do
    client = double("Github::Octkit")

    client.stub(:contents) do |_, options|
      expect(options[:ref]).to eq("some_sha")
      OpenStruct.new(content: "cmVhZG1lIQ==")
    end

    content = subject.fetch("ortuna/progit-bana", "readme.md", "some_sha", client) 
    expect(content.encoding).to eq(Encoding.find("UTF-8"))

  end
end
