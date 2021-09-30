class AmenitiesIndexPresenter
  def initialize(for_reserve: nil)
    @for_reserve = for_reserve
  end

  def amenities
    Amenity
      .where(reserve_id: @for_reserve)
      .in_sort_order
      .map { |amenity| AmenityPresenter.new(amenity) }
  end
end
