class VisitForm
  def initialize
    @visit = Visit.new
  end

  attr_reader :visit

  def arrival_datetime
    # @visit.arrive_at ||
    1.day.from_now.noon
  end

  def departure_datetime
    # @visit.depart_at ||
    2.days.from_now.noon
  end

  def arrival_date
    I18n.l(arrival_datetime, format: :visit_form_input_date)
  end

  def arrival_time
    I18n.l(arrival_datetime, format: :visit_form_input_time)
  end

  def departure_date
    I18n.l(departure_datetime, format: :visit_form_input_date)
  end

  def departure_time
    I18n.l(departure_datetime, format: :visit_form_input_time)
  end
end
