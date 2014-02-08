require 'spec_helper'

describe Github::Hook do
  let(:subject) { Github::Hook }

  before do 
    create_user(id: 42, auth_token: '124abc')
    Repo.create(user_id: 42, id: 99, full_name: 'user/repo', hook_id: 111)
  end

  context '#add_hook' do
    it 'can add a hook to a github repo with correct options' do
      double = double('Octokit::Client')
      subject.stub(:client).and_return(double)

      double.should_receive(:create_hook) do |repo, name, config, options|
        expect(repo).to eq('user/repo')
        expect(name).to eq('web')
        expect(config[:content_type]).to eq('json') 
        expect(config[:url]).to eq('https://arturo.io/hooks/github') 

        expect(options[:events]).to eq(['push'])
        expect(options[:active]).to eq(true)
      end

      subject.create_hook(99)
    end
  end
    
  context '#remove_hook' do
    it 'can remove a hook from github' do
      double = double('Octokit::Client')
      subject.stub(:client).and_return(double)

      double.should_receive(:remove_hook).with('user/repo', 111)
      subject.remove_hook(99)
    end
  end
end
