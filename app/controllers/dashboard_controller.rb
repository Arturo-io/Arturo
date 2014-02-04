class DashboardController < ApplicationController
  protect_from_forgery with: :exception
  def show
    render json: session
  end
end
