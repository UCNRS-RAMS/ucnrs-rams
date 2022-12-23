class ReservesController < ApplicationController
  layout "with_reserve_hero_nav", only: :show

  def index
    @presenter = ReservesIndexPresenter.new
  end

  def show
    reserve = Reserve.includes(personnel: [:user]).find(reserve_id)

    @presenter = ReserveShowPresenter.new(reserve: reserve)
  end

  private

  def reserve_id
    if params[:reserve_filter].present?
      params.permit(:reserve_filter).require(:reserve_filter)
    else
      params.permit(:id).require(:id)
    end
  end
end
