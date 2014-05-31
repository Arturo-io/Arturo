module Stripe
  class Subscribe 
    attr_reader :token, :email, :plan, :user

    def initialize(opts)
      @token = opts[:token]
      @email = opts[:email]
      @plan  = opts[:plan]
      @user  = opts[:user]
    end 

    def execute
      user.update(stripe_customer_token:     customer[:id], 
                  stripe_subscription_token: subscription[:id],
                  plan: selected_plan)
    end

    private
    def subscription
      @subscription ||= (subscription_token && retrieve_subscription) || 
                         create_subscription(@customer)
    end

    def create_subscription(customer)
      customer.subscriptions.create(plan: plan)
    end

    def customer
      @customer ||= (customer_token && retrieve_customer) ||
                     create_customer
    end

    def retrieve_customer
      Stripe::Customer.retrieve(customer_token)
    end

    def retrieve_subscription
      customer
        .subscriptions
        .retrieve(subscription_token).tap do |sub|
          sub.plan = plan
          sub.save
      end
    end

    def subscription_token
      @subscription_token ||= user.stripe_subscription_token
    end

    def customer_token
      @customer_token ||= user.stripe_customer_token
    end

    def create_customer
      Stripe::Customer.create(options)
    end

    def selected_plan
      ::Plan.find_by(name: plan)
    end

    def options
      { card: @token,
        email: @email,} 
    end
  end
end
