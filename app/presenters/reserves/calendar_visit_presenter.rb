class Reserves::CalendarVisitPresenter < Manager::Dashboard::CalendarVisitPresenter
  def amenities
    amenities_scope.map do |amenity|
      Reserves::CalendarAmenityPresenter.new(
        amenity: amenity, visit: visit, date: date,
      )
    end
  end
end
