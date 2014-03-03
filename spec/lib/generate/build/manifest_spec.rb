require 'spec_helper'

describe Generate::Build::Manifest do
   before do
    user  = create_user(auth_token: 'abc1234')
    repo  = Repo.create(id: 1, user: user, full_name: "progit-bana")
    ::Build.create(id: 99, repo: repo, commit: "shaaaabbcc")  
    @build = Generate::Build::Manifest.new(99, [:pdf])

    Pusher.stub(:trigger)
    BuildStatus.any_instance.stub(:update_github)
    BuildStatus.any_instance.stub(:update_pusher)
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

  context '#parsed_options' do
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

 
end