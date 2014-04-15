require 'spec_helper'

describe Generate::Build::Diff do 
  let(:subject) {  Generate::Build::Diff }
  
  before do
    user  = create_user(auth_token: 'abc1234')
    repo  = Repo.create(id: 1, user: user, full_name: "progit-bana")
    ::Build.create(id: 99, repo: repo, commit: "abc", before: '123', after: 'abc')  

    allow_any_instance_of(Generate::Manifest).to receive(:config)
      .and_return({title: "title", author: "author", formats: ["epub", "mobi"]})

    @build = Generate::Build::Manifest.new(99, formats: [:pdf])
    allow_any_instance_of(Build).to receive(:update_status)


    @diff = subject.new(99)
    allow(@diff).to receive(:convert).and_return("Test")
  end

  context '#initialize' do
    it 'sets the build object' do
      expect(@diff.build[:id]).to eq(99)
    end
  end

  context '#upload' do
    it 'sends content to S3' do
      expect(Generate::S3).to receive(:save)
                                .with('some_repo/some_file', 'test')
      @diff.upload('some_repo', 'some_file', 'test')
    end
  end

  context '#execute' do
    it 'uploads a diff file' do
      allow(@diff).to receive(:content).and_return ""
      expect(@diff).to receive(:upload)
        .with('progit-bana', 'abc_diff.pdf', anything)
        .and_return(double().as_null_object)

      @diff.execute
    end

    it 'calls DiffContent to get content' do
      expect(Generate::Compare).to receive(:new) do |options|
        expect(options[:repo]).to eq('progit-bana')
        expect(options[:base]).to eq('123')
        expect(options[:head]).to eq('abc')
        expect(options[:client]).not_to be_nil
      end.and_return(double().as_null_object) 

      @diff.content
    end
  end

end
