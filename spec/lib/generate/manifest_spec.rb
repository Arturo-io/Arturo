require 'spec_helper'

describe Generate::Manifest do
  context '#initialize' do
    it 'takes the repo name as a init param' do 
      Generate::Manifest.new("owner/repo")
    end

    it 'takes an optional github client as a param' do
      Generate::Manifest.new("owner/repo", double("client"))
    end
  end

  context '#config' do
    it 'can retrieve and query the config of a manifest' do
      manifest = Generate::Manifest.new("owner/repo", double("client"))
      manifest.stub(:read_config).and_return(read_fixture_file("manifests/simple.yml"))
      expect(manifest.config[:title]).to eq("some title")
    end
  end
  
  context '#book_content' do
    it 'can get the contents of the whole book as a string' do
      manifest = Generate::Manifest.new("owner/repo")
      manifest.stub(:read_config).and_return(read_fixture_file("manifests/simple.yml"))
      manifest.stub(:read_remote_file) { |path| "#{path}" }
      expect(manifest.book_content).to eq("chapter1.md\nchapter2.md\nchapter3.md\n")
    end
  end
end
