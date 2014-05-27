require 'spec_helper'

describe Stripe::Subscribe do
  let(:subject) { Stripe::Subscribe }

  before do
    @user = create_user
  end

  it 'creates a plan with Stripe' do
    input  = { email: 'someuser@google.com', token: 'sometoken', plan: 'solo', user: @user }
    expect = { email: 'someuser@google.com', card: 'sometoken', plan: 'solo' }

    expect(Stripe::Customer).to receive(:create).with(expect)

    subject.new(input).execute
  end

  it 'updates the users plan' do
    input  = { email: 'someuser@google.com', token: 'sometoken', plan: 'solo', user: @user }
    allow(Stripe::Customer).to receive(:create)

    subject.new(input).execute
    expect(@user.plan.name).to eq("solo")
  end
end
