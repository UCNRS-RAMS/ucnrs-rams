class AmenityPresenter
  def initialize(amenity)
    @amenity = amenity
  end

  attr_reader :amenity

  delegate :id,
    :title,
    :comment,
    :description,
    :image_url,
    to: :amenity

  def rates
    amenity.amenity_rates.includes([:amenity_rate_category]).in_order.map do |rate|
      AmenityRatePresenter.new(rate)
    end
  end

  def unit
    units_type
  end

  def period
    time_type
  end

  def per_sentence
    if period == "each"
      "#{per} #{unit}"
    else
      "#{per} #{unit}/#{per} #{period}"
    end
  end

  def with_image_url?
    image_url.present?
  end

  private

  delegate :time_type, :units_type, to: :amenity

  def per
    I18n.t(".amenities.units.per")
  end
end
