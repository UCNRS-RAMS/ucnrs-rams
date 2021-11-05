class Visits::AmenityRatePresenter
  def initialize(amenity_rate)
    @amenity_rate = amenity_rate
  end

  attr_reader :amenity_rate

  delegate :id, :default_for_user, to: :amenity_rate

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
end
