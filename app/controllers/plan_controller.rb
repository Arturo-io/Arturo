class PlanController < ApplicationController
  protect_from_forgery with: :exception

  before_filter :check_login

  def show
    @current_plan   = current_user.plan
    @email          = current_user.email
    @stripe_pub_key = stripe_pub_key
  end


  private
  def stripe_pub_key
    Rails.configuration.stripe_pub_key
  end
end
