class Reserves::Calendar::AmenityPresenter < Manager::Dashboard::CalendarAmenityPresenter
  include Rails.application.routes.url_helpers

  def visit_link_params
    Reserves::Calendar::BarPresenter.new(
      link_classes: "",
      background_classes: info_link_background_classes,
      text_classes: info_link_text_classes,
      text: info_link_text,
      path: reserve_calendar_visit_path(reserve_id: reserve.id, id: visit.id),
    )
  end
end
