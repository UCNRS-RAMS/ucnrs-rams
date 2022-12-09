class Reserves::AmenitiesController < ApplicationController
  def index
    @presenter = Reserves::AmenitiesIndexPresenter.new(
      reserve_amenities: reserve_amenities
    )
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def reserve
    Reserve.find(reserve_id)
  end

  def reserve_amenities
    reserve.amenities
      .visible
      .not_disable
      .in_sort_order
      .by_group_number
  end
end
