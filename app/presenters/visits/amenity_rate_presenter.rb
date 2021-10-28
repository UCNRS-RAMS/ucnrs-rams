class Visits::AmenityRatePresenter
  def initialize(amenity_rate)
    @amenity_rate = amenity_rate
  end

  attr_reader :amenity_rate

  delegate :id, to: :amenity_rate

  def amount
    "$#{value}"
  end

  def value
    "%0.2f" % [amenity_rate.rate]
  end

  def description
    amenity_rate.amenity_rate_category.description
  end

  def label
    "#{amount} (#{description})"
  end

  def selected_for(amenity)
    if id == amenity.amenity_rate_id
      "selected"
    end
  end
end
