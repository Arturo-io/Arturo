require 'spec_helper'

describe UserSignupEmailWorker do
  let(:subject) { UserSignupEmailWorker }

  before { create_user(id: 42) }

  it 'calls sync on Github::Repo' do
    expect(Notifier).to receive(:send_signup_email) do |user|
      expect(user[:id]).to eq(42)
      double().as_null_object
    end
    subject.new.perform(42)
  end

  it 'queues the job' do
    subject.perform_async(42)
    expect(subject).to have(1).job
  end

end
