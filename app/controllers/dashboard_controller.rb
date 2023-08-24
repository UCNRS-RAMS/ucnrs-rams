class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = DashboardIndexPresenter.new(
      user: current_user
    )
  end
end
