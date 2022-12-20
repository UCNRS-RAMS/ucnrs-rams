class Reserves::Calendar::ShowPresenter < Manager::Dashboard::CalendarShowPresenter
  include Rails.application.routes.url_helpers

  def calendar_path
    reserve_calendar_path(reserve_id: reserve)
  end

  def visits_link_params
    Reserves::Calendar::BarPresenter.new(
      link_classes: visits_link_classes,
      background_classes: visits_link_background_classes,
      text_classes: "",
      text: visits_link_text,
      path: reserve_calendar_visits_path(reserve_id: reserve.id, date: current_date, status: status),
    )
  end

  def visits
    visit_scope.map do |visit|
      Reserves::Calendar::VisitPresenter.new(visit: visit, type: type, status: status)
    end
  end
end
