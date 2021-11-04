class Reserves::AmenitiesController < ApplicationController
  def index
    @page = Reserves::AmenitiesIndexPresenter.new(
      reserve_amenities: amenities.in_sort_order.by_group_number
    )
  end

  private

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def amenities
    Reserve.find(reserve_id).amenities
  end
end
