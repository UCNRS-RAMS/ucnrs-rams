class AmenityVisitPresenter
  def initialize(amenity_visit)
    @amenity_visit = amenity_visit
  end

  delegate_missing_to :amenity_visit

  delegate :title,
    to: :amenity, prefix: true

  delegate :per_sentence, :period, :unit,
    to: :amenity

  def requested_date_range(format = nil)
    DateRangePresenter.value(start_date: arrives, end_date: departs, format: format)
  end

  def total_days
    ((departs.to_date + 1.day) - arrives.to_date).to_i
  end
  
  def requested_date_time_range(format: nil)
    DateTimeRangePresenter.value(start_datetime: arrives, end_datetime: departs, format: format)
  end

  def rate_in_dollar
    "$#{value(rate)}"
  end

  def cost_in_dollar
    "$#{value(subtotal)}"
  end

  def arrives_today?
    arrives.to_date == Time.zone.today
  end

  def departs_today?
    departs.to_date == Time.zone.today
  end

  def to_model
    self
  end

  def to_partial_path
    "amenity_visit"
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
