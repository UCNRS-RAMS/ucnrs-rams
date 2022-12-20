class Reserves::Calendar::VisitPresenter < Manager::Dashboard::CalendarVisitPresenter
  def amenities
    amenities_scope.map do |amenity|
      Reserves::Calendar::AmenityPresenter.new(
        amenity: amenity, visit: visit, date: date,
      )
    end
  end

  def user_info
    user_role
  end
end
