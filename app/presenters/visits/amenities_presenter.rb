class Visits::AmenitiesPresenter
  def initialize(reserve_id: nil)
    @reserve_id = reserve_id
  end

  def amenities
    Amenity
      .where(reserve_id: @reserve_id)
      .in_sort_order
      .map { |amenity| Visits::AmenityPresenter.new(amenity) }
  end
end
