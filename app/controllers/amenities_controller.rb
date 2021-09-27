class AmenitiesController < ApplicationController
  def index
    @page = AmenitiesIndexPresenter.new(
      reserve_amenities: amenities.in_sort_order
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
