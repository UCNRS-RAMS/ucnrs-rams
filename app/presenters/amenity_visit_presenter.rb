class AmenityVisitPresenter
  def initialize(amenity_visit)
    @amenity_visit = amenity_visit
  end

  delegate_missing_to :amenity_visit

  delegate :title,
    to: :amenity, prefix: true

  delegate :per_sentence,
    to: :amenity

  def requested_date_range
    DateRangePresenter.value(start_date: arrives, end_date: departs)
  end

  def rate_in_dollar
    "$#{value(rate)}"
  end

  def cost_in_dollar
    "$#{value(subtotal)}"
  end
  
  private

  attr_reader :amenity_visit

  def amenity
    AmenityPresenter.new(amenity_visit_amenity)
  end

  def amenity_visit_amenity
    amenity_visit.amenity
  end

  def value(num)
    "%0.2f" % [num]
  end
end
