class AmenityPresenter
  def initialize(amenity)
    @amenity = amenity
  end

  attr_reader :amenity

  delegate :id,
    :title,
    :description,
    :image_url,
    to: :amenity

  def checkbox_id
    "amenity-checkbox-#{id}"
  end

  def rates
    amenity.amenity_rates.in_order.map do |rate|
      AmenityRatePresenter.new(rate)
    end
  end

  def unit
    amenity.units_type
  end

  def period
    amenity.time_type
  end
end
