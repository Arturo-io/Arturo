require 'spec_helper'

describe Generate::Build::Manifest do
   before do
    user  = create_user(auth_token: 'abc1234')
    repo  = Repo.create(id: 1, user: user, full_name: "progit-bana")

    allow_any_instance_of(Generate::Manifest).to receive(:config)
      .and_return({title: "title", author: "author", formats: ["epub", "mobi"]})

    ::Build.create(id: 99, repo: repo, commit: "shaaaabbcc")  
    @build = Generate::Build::Manifest.new(99, formats: [:pdf])

    allow(Pusher).to receive(:trigger)
    allow_any_instance_of(BuildStatus).to receive(:update_github)
    allow_any_instance_of(BuildStatus).to receive(:update_pusher)

  end

  context '#content' do
    it 'can get the content for a repo' do
      allow_any_instance_of(Generate::Manifest).to receive(:book_content)
        .and_return("some repos content")
      content = @build.content("ortuna/some_repo", "some_sha")
      expect(content).to eq("some repos content")
    end

   it 'caches the content for the sha' do
     expect(Generate::Manifest).to receive(:new)
                                    .once
                                    .and_return(double().as_null_object)

      @build.content("ortuna/some_repo", "some_sha")
      @build.content("ortuna/some_repo", "some_sha")
    end
  end

  context '#formats' do
    it 'prefers manifest formats to passed in ones' do
      expect(@build.formats).to eq([:epub, :mobi]) 
    end

    it 'removes dont send format to docverter' do
      expect(Generate::Convert).to receive(:new) do |_, _, opts|
        expect(opts[:formats]).to be_nil
        double().as_null_object
      end

      @build.convert("content", :html)
    end
  end

  context '#options' do
    it 'can get options for a repo' do
      options = @build.config("ortuna/some_repo", "some_sha")
      expect(options[:title]).to eq("title")
      expect(options[:author]).to eq("author")
    end

    it 'caches the options for the sha' do
      expect(Generate::Manifest).to receive(:new)
                                     .once
                                     .and_return(double().as_null_object)

      @build.config("ortuna/some_repo", "some_sha")
      @build.config("ortuna/some_repo", "some_sha")
    end

    it ' raises on invalid options' do
      allow(Generate::ManifestOptions).to receive_message_chain(:new, :validate!) do
        raise "Invalid options"
      end
      
      expect { 
        @build.config("ortuna/some_repo", "some_sha")
      }.to raise_error
    end
  end

  context '#parsed_options' do
    it 'removes the pages key/value from config hash' do
      double = double("Generage::Convert")
      expect(double).to receive(:run)

      allow(@build).to receive(:config).and_return("pages" => [1,2,3], 
                                                   table_of_contents: false, 
                                                   another_option: true)

      expect(Generate::Convert).to receive(:new) do |_, _, options|
        expect(options[:pages]).to eq(nil)
        expect(options["pages"]).to eq(nil)
        double
      end
      @build.convert("#some content", :html)
    end
  end

 
end
