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
      Stripe::Customer.create(options)
      user.update(plan: selected_plan)
    end

    private
    def selected_plan
      ::Plan.find_by(name: plan)
    end

    def options
      { card: @token,
        email: @email,
        plan:  @plan } 
    end
  end
end
