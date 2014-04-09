require 'spec_helper'

describe Github::Repo do
  let(:subject) { Github::Repo }
  let(:example_repo_list) do
    [
      OpenStruct.new({ attrs: {id: 1, name: "expected_name0"} }),
      OpenStruct.new({ attrs: {id: 2, name: "expected_name1"} }),
      OpenStruct.new({ attrs: {id: 3, name: "expected_name2"} }),
      OpenStruct.new({ attrs: {id: 4, name: "expected_name3"} }),
    ]
  end

  let(:orgs) do
    [{ "login" => "railsrumble" },
     { "login" => "arturo-io"}] 
  end

  before do
    @client = double("Octokit::Client")
    allow(@client).to receive(:orgs).and_return(orgs)
  end

  context '#fetch_repo' do
    it 'can get a single repo from github' do
      expect(@client).to receive(:repo).and_return({hash: "value"})

      repo_hash = subject.fetch_repo(@client, "ortuna/progit-bana")
      expect(repo_hash).to eq({hash: "value"})
    end
  end

  context '#commit' do
    it 'can get the commit on a repo' do
      expect(@client).to receive(:commit).and_return(OpenStruct.new(sha: "some_sha"))

      commit = subject.commit(@client, "ortuna/progit-bana", "some_sha")
      expect(commit.sha).to eq("some_sha")
    end
  end

  context '#last_commit' do
    it 'gets the latest commit form github' do
      allow(@client).to receive_message_chain(:commits, :first).and_return("expected")

      commit = subject.last_commit(@client, "ortuna/progit-bana")
      expect(commit).to eq("expected")
    end

    it 'should turn off auto_pagination for github' do
      @client = double("Octokit::Client").as_null_object
      expect(Octokit).to receive(:auto_paginate=).twice
      subject.last_commit(@client, "ortuna/progit-bana")
    end

 end

  context '#sync' do
    before {  create_user(id: 42, login: "ortuna") }

    it 'can sync from github' do
      expect(@client).to receive(:orgs).and_return(orgs)
      expect(@client).to receive(:repos).and_return(example_repo_list).exactly(3).times

      expect(subject).to receive(:client).and_return(@client)

      subject.sync(42)
      expect(Repo.count).to eq(4)
      expect(Repo.find(1)[:name]).to eq("expected_name0")
    end
  end


  context '#create_from_array' do
    before {  create_user(id: 42, login: "ortuna") }

    it 'creates repos from an array and user_id' do
      subject.create_from_array(42, example_repo_list) 

      expect(Repo.count).to eq(4)
      expect(Repo.where(user_id: 42).count).to eq(4)
      expect(Repo.first[:name]).to eq("expected_name0")
    end

    it 'updates an already existing repo' do
      Repo.create(id: 1, name: "old_name")

      repo_list = [ OpenStruct.new({ attrs: {id: 1, name: "expected_name"} }) ]
      subject.create_from_array(42, repo_list) 

      expect(Repo.count).to eq(1)
      expect(Repo.find(1)[:name]).to eq("expected_name")
    end
  end

  context '#fetch_from_github' do
    it 'fetches a list of repos from client' do
      allow(@client).to receive(:repos).and_return(example_repo_list)

      repos = subject.fetch_from_github(@client) 
      expect(repos.first.attrs[:name]).to eq("expected_name0")
    end

    it 'fetches a list of repos from every org' do
      expect(@client).to receive(:orgs).and_return(orgs)
      expect(@client).to receive(:repos).with("railsrumble").and_return(example_repo_list)
      expect(@client).to receive(:repos).with("arturo-io").and_return(example_repo_list)
      expect(@client).to receive(:repos).and_return(example_repo_list)

      repos = subject.fetch_from_github(@client) 
      expect(repos.count).to eq(12)
    end
  end

  context '#update_attributes' do
    before do
      @hash  = OpenStruct.new({ attrs: {} })
      @model = Repo.new
    end

    it 'sets the user_id correctly' do
      subject.update_attributes(42, @hash, @model)
      expect(@model.user_id).to eq(42)
    end

    it 'sets the html_url' do
      href_double = double()
      allow(href_double).to receive(:href).and_return("http://example.com")
      allow(@hash).to receive(:rels).and_return(html: href_double)

      subject.update_attributes(42, @hash, @model)
      expect(@model.html_url).to eq("http://example.com")
    end

    it 'sets the github org/author' do
      allow(@hash).to receive_message_chain(:owner, :login).and_return("Arturo-io")
      subject.update_attributes(42, @hash, @model)

      expect(@model.org).to eq("arturo-io")
    end

  end

end
