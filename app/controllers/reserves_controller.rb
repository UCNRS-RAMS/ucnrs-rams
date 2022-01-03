class ReservesController < ApplicationController
  def index
    @presenter = ReservesIndexPresenter.new
  end

  def show
    reserve = Reserve.includes(personnel: [:user, :avatar_attachment]).find(reserve_id)

    @presenter = ReserveShowPresenter.new(reserve: reserve)
  end

  private

  def reserve_id
    params.permit(:id).require(:id)
  end
end
