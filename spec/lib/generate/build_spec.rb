require 'spec_helper'

describe Generate::Build do
  before do
    user  = create_user(auth_token: 'abc1234')
    repo  = Repo.create(id: 1, user: user, full_name: "progit-bana")
    ::Build.create(id: 99, repo: repo, commit: "shaaaabbcc")  
    @build = Generate::Build.new(99, [:pdf])

    Pusher.stub(:trigger)
    BuildStatus.any_instance.stub(:update_github)
    BuildStatus.any_instance.stub(:update_pusher)
  end

  it 'creates the right client' do
    client = @build.github_client('abc1234')
    expect(client.access_token).to eq('abc1234')
  end

  it 'has default options' do
    expect(@build.options[:table_of_contents]).to eq(true)
  end

  it 'sends the options to the converter' do
    Generate::Convert.should_receive(:run) do |_, _, options| 
      expect(options[:table_of_contents]).to eq(true)
    end

    @build.stub(:config).and_return({})
    @build.convert("#some content", :html)
  end


  it 'can save to S3' do
    Generate::S3.should_receive(:save) do |path, content|
      expect(path).to eq("some_repo/some_file.txt")
      expect(content).to eq("content")
    end

    @build.upload("some_repo", "some_file.txt", "content", :txt)
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

  context '#convert' do
    it 'can convert content to a format' do
      Generate::Convert.stub(:run).and_return("<h1>some content</h1>")
      @build.stub(:config).and_return({})
      content = @build.convert("#some content", :html)
      expect(content).to match("<h1>some content</h1>")
    end
    
    it 'sends the options from the manifest' do
      @build.stub(:config).and_return(table_of_contents: false, another_option: true)
      Generate::Convert.should_receive(:run) do |_, _, options|
        expect(options[:table_of_contents]).to eq(false)
        expect(options[:another_option]).to eq(true)
      end
      
      @build.convert("#some content", :html)
    end

    it 'removes the pages key/value from config hash' do
      @build.stub(:config).and_return("pages" => [1,2,3], 
                                      table_of_contents: false, 
                                      another_option: true)

      Generate::Convert.should_receive(:run) do |_, _, options|
        expect(options[:pages]).to eq(nil)
        expect(options["pages"]).to eq(nil)
      end
      
      @build.convert("#some content", :html)
 
    end

  end
  context '#content' do
    it 'can get the content for a repo' do
      Generate::Manifest
        .any_instance
        .stub(:book_content)
        .and_return("some repos content")
      content = @build.content("ortuna/some_repo", "some_sha")
      expect(content).to eq("some repos content")
    end

   it 'caches the content for the sha' do
      Generate::Manifest
        .should_receive(:new)
        .once
        .and_return(double().as_null_object)

      @build.content("ortuna/some_repo", "some_sha")
      @build.content("ortuna/some_repo", "some_sha")
    end
  end

  context '#notifications' do

    it 'updates build status on convert' do
      Generate::Convert.stub(:run) 

      Build.any_instance.should_receive(:update_status).with("building pdf")
      @build.stub(:config).and_return({})
      @build.convert("#title", :pdf)
    end

    it 'updates build status on upload' do
      Generate::S3.stub(:save) 

      Build.any_instance.should_receive(:update_status).with("uploading pdf")
      @build.upload("my_repo", "some_file.txt", "title", :pdf)
    end

  end

  context '#options' do
    it 'can get options for a repo' do
      Generate::Manifest
        .any_instance
        .stub(:config)
        .and_return({option1: true, option2: false})

      options = @build.config("ortuna/some_repo", "some_sha")
      expect(options[:option1]).to eq(true)
      expect(options[:option2]).to eq(false)
    end

    it 'caches the options for the sha' do
      Generate::Manifest
        .should_receive(:new)
        .once
        .and_return(double().as_null_object)

      @build.config("ortuna/some_repo", "some_sha")
      @build.config("ortuna/some_repo", "some_sha")
    end
  end

end
