require 'spec_helper'

describe Generate::Build do
  before do
    user  = create_user(auth_token: 'abc1234')
    repo  = Repo.create(id: 1, user: user, full_name: "progit-bana")
    ::Build.create(id: 99, repo: repo, commit: "shaaaabbcc")  
    @build = Generate::Build.new(99, [:pdf])
  end

  it 'creates the right client' do
    client = @build.github_client('abc1234')
    expect(client.access_token).to eq('abc1234')
  end

  it 'can convert content to a format' do
    Generate::Convert.stub(:run).and_return("<h1>some content</h1>")
    content = @build.convert("#some content", :html)
    expect(content).to match("<h1>some content</h1>")
  end

  it 'can get the content for a repo' do
    Generate::Manifest
      .any_instance
      .stub(:book_content)
      .and_return("some repos content")
    content = @build.content("ortuna/some_repo", "some_sha")
    expect(content).to eq("some repos content")
  end

  it 'can save to S3' do
    Generate::S3.should_receive(:save) do |path, content|
      expect(path).to eq("some_repo/some_file.txt")
      expect(content).to eq("content")
    end

    @build.upload("some_repo", "some_file.txt", "content")
  end

  it 'has the right options' do
    build = @build
    expect(build.repo.id).to eq(1)
    expect(build.full_name).to eq("progit-bana")
    expect(build.auth_token).to eq('abc1234')
    expect(build.formats).to eq([:pdf])
  end

  it 'find the correct sha to build from' do
    expect(@build.sha).to eq("shaaaabbcc")
  end

  it 'can create an asset' do
    @build.should_receive(:sha).twice.and_return("aabbccdd")
    @build.should_receive(:content).and_return("")
    @build.should_receive(:convert).and_return("")
    @build.should_receive(:upload).and_return(OpenStruct.new(url: "some_asset.pdf"))

    build = @build
    expect(build.execute).to eq(["some_asset.pdf"]) 
  end

end
