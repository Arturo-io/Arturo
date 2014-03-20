require 'spec_helper'

describe Github::Org do
  let(:subject) { Github::Org }
  let(:fake_orgs) {
    [{ "login" => "railsrumble" },
     { "login" => "arturo-io"}] 
  }

  it 'can fetch a org login list from github' do
    client = double("Octokit::Client")
    expect(client).to receive(:orgs).and_return(fake_orgs)

    expect(subject.fetch_login_list(client)).to eq(["railsrumble", "arturo-io"])
  end

  it 'can fetch the orgs from github' do
    client = double("Octokit::Client")
    expect(client).to receive(:orgs).and_return(fake_orgs)

    orgs = subject.fetch_from_github(client)
    expect(orgs[0]["login"]).to eq("railsrumble")
    expect(orgs[1]["login"]).to eq("arturo-io")
  end
end
