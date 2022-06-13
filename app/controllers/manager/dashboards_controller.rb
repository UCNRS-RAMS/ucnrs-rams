class Manager::DashboardsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_manager!

  def show
    @presenter = Manager::DashboardShowPresenter.new(
      reserve: reserve,
    )
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def reserve
    Reserve.find(reserve_id)
  end
end
