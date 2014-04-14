require 'spec_helper'
class ExampleBuilder < Generate::Build::Generic

end

describe Generate::Build:: Generic do
  before do
    @user  = create_user(auth_token: 'abc1234')
    @repo  = Repo.create(user: @user, full_name: "progit-bana")
    ::Build.create(id: 99, repo: @repo, commit: "shaaaabbcc")  
    @build = ExampleBuilder.new(99, formats: [:pdf])

    allow(Pusher).to receive(:trigger)
    allow_any_instance_of(BuildStatus).to receive(:update_github)
    allow_any_instance_of(BuildStatus).to receive(:update_pusher)
  end

  it 'creates the right client' do
    client = @build.github_client('abc1234')
    expect(client.access_token).to eq('abc1234')
  end

  it 'has default options' do
    expect(@build.options[:table_of_contents]).to eq(true)
  end

  it 'sends the options to the converter' do
    expect(Generate::Convert).to receive(:new) do |_, _, options| 
      expect(options[:table_of_contents]).to eq(true)
      expect(options[:file_list_download]).not_to be_nil
      double().as_null_object.tap do |d|
        expect(d).to receive(:run)
      end
    end

    @build.convert("#some content", :html)
  end

  it 'defaults formats to :pdf' do
    build = ExampleBuilder.new(99)
    expect(build.formats).to eq([:pdf])
  end

  it 'does not send self-contained: true to converter unless format is html' do
    dbl = double().as_null_object.tap do |d|
      expect(d).to receive(:run)
    end

    expect(Generate::Convert).to receive(:new) do |_, _, options| 
      expect(options["self-contained"]).to eq(true)
      dbl
    end

    @build.convert("#some content", :html)

    expect(Generate::Convert).to receive(:new) do |_, _, options| 
      expect(options["self-contained"]).to eq(nil)
      dbl
    end

    @build.convert("#some content", :pdf)
  end


  it 'can save to S3' do
    expect(Generate::S3).to receive(:save) do |path, content|
      expect(path).to eq("some_repo/some_file.txt")
      expect(content).to eq("content")
    end

    @build.upload("some_repo", "some_file.txt", "content", :txt)
  end

  it 'has the right options' do
    expect(@build.repo.id).to eq(@repo.id)
    expect(@build.full_name).to eq("progit-bana")
    expect(@build.auth_token).to eq('abc1234')
    expect(@build.formats).to eq([:pdf])
  end

  it 'removes :formats from being sent to the server' do
    expect(@build.options[:formats]).to be_nil
  end

  it 'converts formats to symbols' do
    build = ExampleBuilder.new(99, formats: ["pdf", "html", "mobi"])
    expect(build.formats).to eq([:pdf, :html, :mobi])
  end

  it 'find the correct sha to build from' do
    expect(@build.sha).to eq("shaaaabbcc")
  end

  it 'can create an asset' do
    expect(@build).to receive(:sha).twice.and_return("aabbccdd")
    expect(@build).to receive(:content).and_return("")
    expect(@build).to receive(:convert).and_return("")
    expect(@build).to receive(:upload).and_return(OpenStruct.new(url: "some_asset.pdf"))

    expect(@build.execute).to eq(["some_asset.pdf"]) 
  end

  context '#tree' do
    before do
      @directory1 = { "path" => "some_dir",  "type" => "tree" }
      @directory2 = { "path" => "some_dir1", "type" => "tree" }
      @file1      = { "path" => "file.txt",  "type" => "blob" }
      @file2      = { "path" => "file2.txt", "type" => "blob" }
      @file3      = { "path" => "file2.pdf", "type" => "blob" }
      @tree       = OpenStruct.new(tree:[@directory1, @file1, @file2, @directory2, @file3])
    end

    it 'can get the file tree from a git repo' do
      expect(Github::Tree).to receive(:fetch)
                               .with(anything, "progit-bana", "shaaaabbcc")
                               .and_return(@tree)
      expect(@build.tree("progit-bana", "shaaaabbcc")).to eq(["file.txt", "file2.txt"])
    end

    it 'returns only txt/md files and not directories' do
      allow(Github::Tree).to receive(:fetch).and_return(@tree)
      expect(@build.tree("some_repo", "some_sha")).to eq(["file.txt", "file2.txt"])
    end

  end

  context '#content' do
    it 'can get content from the repo tree' do
      Transform.plugins = [Transform::NewLine]
      allow(Github::File).to receive(:fetch) { |_, path, _, _| path }
      allow(@build).to receive(:tree).and_return ['02-chap2/chap2.txt', '01-chap1/chap1.txt']
      content = @build.content("some_repo", "some_sha")
      expect(content).to eq("01-chap1/chap1.txt\n02-chap2/chap2.txt\n")
    end
  end

  context '#convert' do
    it 'can convert content to a format' do
      allow(Generate::Convert).to receive_message_chain(:new, :run).and_return("<h1>some content</h1>")
      content = @build.convert("#some content", :html)
      expect(content).to match("<h1>some content</h1>")
    end
  
    it 'sends the options from the manifest' do
      allow(@build).to receive(:options)
                        .and_return(table_of_contents: false, another_option: true)

      expect(Generate::Convert).to receive(:new) do |_, _, options|
        expect(options[:table_of_contents]).to eq(false)
        expect(options[:another_option]).to eq(true)

        double().as_null_object.tap do |d|
          expect(d).to receive(:run)
        end
      end

      @build.convert("#some content", :html)
    end

  end

  context '#notifications' do

    it 'updates build status on convert' do
      allow(Generate::Convert).to receive(:new)
                                    .and_return(double().as_null_object) 

      allow_any_instance_of(Build).to receive(:update_status).with("building pdf")
      @build.convert("#title", :pdf)
    end

    it 'updates build status on upload' do
      allow(Generate::S3).to receive(:save) 

      allow_any_instance_of(Build).to receive(:update_status).with("uploading pdf")
      @build.upload("my_repo", "some_file.txt", "title", :pdf)
    end

  end


end
