require 'spec_helper'

describe Generate::Book do
  let(:subject) { Generate::Book }  

  it 'can find the right constant' do
    book = subject.new(1, [:xyz]) 
    allow(book).to receive(:has_manifest?).and_return false
    expect(book.builder).to eq(Generate::Build::Generic)

    allow(book).to receive(:has_manifest?).and_return true
    expect(book.builder).to eq(Generate::Build::Manifest)
  end



  context 'with data' do
    before do
      @plan  = Plan.create(name: :simple, repos: 1)
      @user  = create_user(id: 42, auth_token: "token", plan: @plan)
      @repo  = Repo.create(id: 99, user: @user, full_name: 'full_name', private: true)
      Build.create(id: 11, repo: @repo, commit: "some_sha")
      Follower.create(user: @user, repo: @repo)
    end

    it 'delegates execute to the constant' do
      generate = subject.new(11, [:pdf])
      allow(generate).to receive_message_chain(:builder, :new, :execute)
        .and_return :executed

      expect(generate.execute).to eq(:executed)
    end

    context 'plan limit' do
      it 'does not check limit on public builds' do
        @repo.update(private: false)
        generate = subject.new(11, [:pdf])
        allow(generate).to receive_message_chain(:builder, :new, :execute)
        expect(generate).not_to receive(:check_build_limit)

        generate.execute
      end 

      it 'raises PrivateRepoLimitReached' do
        @plan.update(repos: 0)
        double = double("builder").as_null_object
        book_build = subject.new(11, [:pdf])

        expect { 
          book_build.execute
        }.to raise_error(subject::PrivateRepoLimitReached)
      end
    end


    context '#lookup_manifest' do
      it 'sends the right arguments to Generate::Manifest' do
        expect(Generate::Manifest).to receive(:new) do |full_name, sha, client|
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

end
