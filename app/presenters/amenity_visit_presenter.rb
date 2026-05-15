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

  def requested_short_date_range(format: nil)
    ShortDateRangePresenter.value(start_date: arrives.to_date, end_date: departs.to_date, format: format)
  end

  def total_days
    calc_units_of_time
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

  def status_class
    if invoice_status == "INVOICED"
      "invoiced amenity-status"
    elsif invoice_status == "NEVER INVOICED"
      "amenity-status"
    end
  end

  def disable
    "disable" if invoice_status == "INVOICED"
  end

  def invoice_status
    if (invoiced? && invoice_now)
      "INVOICED"
    elsif (!invoiced? && !invoice_now)
      "NEVER INVOICED"
    end
  end

  delegate :invoiced?, to: :amenity_visit

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
