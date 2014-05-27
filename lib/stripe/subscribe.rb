module Stripe
  class Subscribe 
    attr_reader :token, :email, :plan
    def initialize(opts)
      @token = opts[:token]
      @email = opts[:email]
      @plan  = opts[:plan]
    end 

    def execute
      Stripe::Customer.create(options)
    end

    private
    def options
      { card: @token,
        email: @email,
        plan:  @plan } 
    end
  end
end
