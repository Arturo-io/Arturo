require 'spec_helper'

describe Stripe::Subscribe do
  let(:subject) { Stripe::Subscribe }

  it 'creates a plan with Stripe' do
    input  = { email: 'someuser@google.com', token: 'sometoken', plan: 'solo' }
    expect = { email: 'someuser@google.com', card: 'sometoken', plan: 'solo' }

    expect(Stripe::Customer).to receive(:create).with(expect)

    subject.new(input).execute
  end
end
