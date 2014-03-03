class BadgeController < ApplicationController
  def show
    redirect_to RepoBadge.new(params).url 
  end
end
