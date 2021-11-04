class AmenityRatePresenter
  def initialize(amenity_rate)
    @amenity_rate = amenity_rate
  end

  attr_reader :amenity_rate

  delegate :id,
    :rate,
    :amenity_rate_category,
    to: :amenity_rate

  delegate :description,
    to: :amenity_rate_category

  delegate :per_sentence,
    to: :amenity

  def amount
    "$#{value}"
  end

  def value
    "%0.2f" % [rate]
  end

  def amenity
    AmenityPresenter.new(amenity_rate_amenity)
  end

  private

  delegate :amenity,
    to: :amenity_rate, prefix: true
end
