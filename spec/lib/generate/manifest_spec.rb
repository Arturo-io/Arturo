require 'spec_helper'

describe Generate::Manifest do
  context '#initialize' do
    it 'takes the repo name as a init param' do 
      Generate::Manifest.new("owner/repo")
    end

    it 'takes an optional sha as a param' do
      Generate::Manifest.new("owner/repo", "some_sha")
    end

    it 'takes an optional github client as a param' do
      Generate::Manifest.new("owner/repo", "some_sha", double("client"))
    end
  end

  context '#read_remote_file' do
    it 'calls Github::File with the correct params' do
      Github::File.should_receive(:fetch) do |repo, path, _, sha|
        expect(repo).to eq("owner/repo")
        expect(path).to eq("some_file.xyz")
        expect(sha).to  eq(nil)
      end

      manifest = Generate::Manifest.new("owner/repo")
      manifest.read_remote_file("some_file.xyz")
    end

    it 'passes the correct sha to Github::File' do
      Github::File.should_receive(:fetch) do |_, _, _, sha|
        expect(sha).to  eq("some_sha")
      end

      manifest = Generate::Manifest.new("owner/repo", "some_sha")
      manifest.read_remote_file("some_file.xyz")
    end
  end

  context '#config' do
    it 'can retrieve and query the config of a manifest' do
      manifest = Generate::Manifest.new("owner/repo")
      manifest.stub(:read_config).and_return(read_fixture_file("manifests/simple.yml"))
      expect(manifest.config[:title]).to eq("some title")
    end

    it 'can retrieve and query the config from a certain SHA' do
      manifest = Generate::Manifest.new("owner/repo", "some_sha")
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
