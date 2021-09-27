class AmenitiesIndexPresenter
  def initialize(reserve_amenities:)
    @reserve_amenities = reserve_amenities
  end

  def amenities
    reserve_amenities.map do |amenity|
      AmenityPresenter.new(amenity)
    end
  end

  private

  attr_reader :reserve_amenities
end
