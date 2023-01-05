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
    params.permit(:id).require(:id)
  end
end
