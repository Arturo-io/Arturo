require 'spec_helper'

describe FailedBuildEmailWorker do
  let(:subject) { FailedBuildEmailWorker }

  before do 
    create_user(id: 42, email: 'some_user@example.com') 
    create_repo(id: 99, user_id: 42, full_name: "some_repo")
    create_build(id: 55, repo_id: 99)
  end

  it 'calls sync on Github::Repo' do
    expect(Notifier).to receive(:send_failed_email) do |emails, build|
      expect(emails.first).to eq('some_user@example.com') 
      expect(build[:id]).to eq(55)
      double().as_null_object
    end

    subject.new.perform(55)
  end

  it 'queues the job' do
    subject.perform_async(55)
    expect(subject).to have(1).job
  end

end
