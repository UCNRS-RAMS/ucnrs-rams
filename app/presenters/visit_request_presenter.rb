class VisitRequestPresenter
  def initialize(visit_request)
    @visit_request = visit_request
  end

  attr_reader :visit_request

  delegate :id, :status, :start_date, :end_date, to: :visit_request

  def requested_date_range
    DateRangePresenter.value(start_date: start_date, end_date: end_date)
  end

  def requested_reserve_name
    visit_request.name
  end
end
