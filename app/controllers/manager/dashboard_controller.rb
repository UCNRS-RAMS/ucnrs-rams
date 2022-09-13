class Manager::DashboardController < ApplicationController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  def show
    @presenter = Manager::DashboardShowPresenter.new(
      reserve: current_reserve,
    )
  end
end
