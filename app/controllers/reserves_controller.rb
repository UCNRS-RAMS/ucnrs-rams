class ReservesController < ApplicationController
  def index
    @page = ReservesIndexPresenter.new
  end

  def show
    reserve = Reserve.includes(personnel: [:user, :avatar_attachment]).find(reserve_id)

    @page = ReserveShowPresenter.new(reserve: reserve)
  end

  private

  def reserve_id
    params.permit(:id).require(:id)
  end
end
