require 'spec_helper'

describe Stripe::Subscribe do
  let(:subject) { Stripe::Subscribe }

  before do
    @user    = create_user
    @input   = { email: 'someuser@google.com', token: 'sometoken', plan: 'solo', user: @user }
    @subject = subject.new(@input)
  end

  it 'creates a plan with Stripe' do
    expect = { email: 'someuser@google.com', card: 'sometoken'}
    expect(Stripe::Customer).to receive(:create)
      .with(expect).and_return(double.as_null_object)

    @subject.execute
  end

  context 'with fake customer' do
    before do
      fake_customer     = double("Customer").as_null_object
      fake_subscription = double("Subscription").as_null_object

      allow(fake_customer).to receive(:[]).with(:id)
        .and_return("customer_token")

      allow(fake_customer).to receive_message_chain(:subscriptions, :create)
        .and_return(fake_subscription)

      allow(fake_subscription).to receive(:[]).with(:id)
        .and_return("subscription_token")

      allow(@subject).to receive(:create_customer)
        .and_return(fake_customer)
    end

    it 'updates the users plan' do
      @subject.execute
      expect(@user.plan.name).to eq("solo")
    end

    it 'update the users customer token' do
      @subject.execute
      expect(@user.stripe_customer_token).to eq("customer_token")
    end

    it 'updates the users subscription token' do
      @subject.execute
      expect(@user.stripe_subscription_token).to eq("subscription_token")
    end

    it 'uses the users customer token if they already have one' do
      @input[:plan] = "multi_pass"
      @subject = subject.new(@input)
      @user.update(stripe_customer_token: '1234')

      double = double("Customer")

      expect(double).to receive_message_chain(:subscriptions, :create)
        .and_return(id: 'new_subscription_token')

      allow(double).to receive(:[]).with(:id)
        .and_return("subscription_token")

      expect(Stripe::Customer).to receive(:retrieve)
        .with('1234')
        .and_return(double)

      @subject.execute

      expect(@user.stripe_subscription_token).to eq("new_subscription_token")
      expect(@user.plan.name).to eq("multi_pass")
    end

    it 'updates a user subscription if they already have one' do
      @input[:plan] = "multi_pass"
      @subject = subject.new(@input)
      @user.update(stripe_customer_token: '1234', stripe_subscription_token: 'xyz')

      customer     = double("Customer")
      subscription = double("Subscription")

      expect(subscription).to receive(:[]).with(:id).and_return("new_subscription_token")
      expect(subscription).to receive(:plan=).with("multi_pass")
      expect(subscription).to receive(:save)

      allow(customer).to receive_message_chain(:subscriptions, :retrieve)
        .and_return(subscription)

      allow(customer).to receive(:[]).with(:id)
      allow(Stripe::Customer).to receive(:retrieve)
        .with('1234')
        .and_return(customer)

      @subject.execute

      expect(@user.stripe_subscription_token).to eq("new_subscription_token")
      expect(@user.plan.name).to eq("multi_pass")

    end
  end
end
