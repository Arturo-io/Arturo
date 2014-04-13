require 'spec_helper'

describe Generate::Build::Diff do 
  let(:subject) {  Generate::Build::Diff }
  
  before do
    user  = create_user(auth_token: 'abc1234')
    repo  = Repo.create(id: 1, user: user, full_name: "progit-bana")
    ::Build.create(id: 99, repo: repo, commit: "abc")  

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
      expect(Generate::DiffContent).to receive(:new)
        .with(repo: 'progit-bana', base: 'HEAD', head: 'abc')
        .and_return(double().as_null_object) 

      @diff.content
    end
  end

  context '#base' do
    it 'selects HEAD~2 when sha == last comit' do
      allow(@diff).to receive(:last_commit).and_return('abc')
      expect(@diff.base).to eq('HEAD~2')
    end

    it 'returns master if the sha != last commit' do
      allow(@diff).to receive(:last_commit).and_return('xyz')
      expect(@diff.base).to eq('master')
    end
  end

  context '#last_commit' do
    it 'gets the last commit on the repo' do
      expect(Github::Repo).to receive(:last_commit) do |_client, repo|
        expect(repo).to eq('progit-bana')
        OpenStruct.new(sha: 'some_sha')
      end

      expect(@diff.send(:last_commit)).to eq('some_sha')
    end
  end
end
