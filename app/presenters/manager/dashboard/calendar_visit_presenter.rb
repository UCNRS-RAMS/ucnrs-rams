class Manager::Dashboard::CalendarVisitPresenter < VisitPresenter
  def initialize(visit:, type: nil, status: nil, date: Date.current)
    super(visit)
    @date = date
    @type = type
    @status = status
  end

  attr_reader :type, :status
  attr_accessor :date

  def user_visits_count(for_date = date)
    user_visits.pluck(:arrives_at, :departs_at, :count).select do |r|
      for_date.between?(r[0].to_date, r[1].to_date)
    end.sum(&:third)
  end

  def display_visit?
    status.in?(["all", visit_status])
  end

  def amenities
    amenities_scope.map do |amenity|
      Manager::Dashboard::CalendarAmenityPresenter.new(
        amenity: amenity, visit: visit, date: date,
      )
    end
  end

  private

  def display_amenity?(amenity)
    type.in?(["visits_and_amenities", "amenities_only", amenity.group_number])
  end

  def amenities_scope
    visit.amenities.distinct.select { |amenity| display_amenity?(amenity) }
  end
end
