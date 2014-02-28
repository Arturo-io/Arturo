require 'spec_helper'

describe Generate::Book do
  let(:subject) { Generate::Book }  

  it 'can find the right constant' do
    book = subject.new(1, [:xyz]) 
    book.stub(:has_manifest?).and_return false
    expect(book.builder).to eq(Generate::Build::Generic)

    book.stub(:has_manifest?).and_return true
    expect(book.builder).to eq(Generate::Build::Manifest)
  end


  it 'delegates execute to the constant' do
    book = subject.new(1, [:pdf])
    book.stub_chain(:builder, :new, :execute).and_return :executed

    expect(book.execute).to eq(:executed)
  end

  context '#lookup_manifest' do
    before do
      user  = create_user(id: 42, auth_token: "token")
      repo  = Repo.create(id: 99, user: user, full_name: 'full_name')
      Build.create(id: 11, repo: repo, commit: "some_sha")
    end

    it 'sends the right arguments to Generate::Manifest' do
      Generate::Manifest.should_receive(:new) do |full_name, sha, client|
        expect(full_name).to eq("full_name")
        expect(sha).to eq("some_sha")
        expect(client.access_token).to eq("token")
        double().as_null_object
      end

      book_build = subject.new(11, [:pdf])
      book_build.has_manifest?
    end
  end
end
