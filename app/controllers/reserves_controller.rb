class ReservesController < ApplicationController
  def index
    @page = ReservesIndexPresenter.new
  end

  def show
    @page = ReserveShowPresenter.new(
      reserve: reserve,
      personnel: Personnel.fake,
    )
  end

  private

  def reserve_id
    params.permit(:id).require(:id)
  end

  def reserve
    reserve = Reserve.find(reserve_id)
  end
end
