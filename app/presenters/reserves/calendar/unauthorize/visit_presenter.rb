class Reserves::Calendar::Unauthorize::VisitPresenter < Home::Calendar::VisitPresenter
  def visit_link_params
    Reserves::Calendar::Unauthorize::BarPresenter.new(
      link_classes: "",
      background_classes: info_link_background_classes,
      text_classes: info_link_text_classes,
      text: info_link_text,
      path: reserve_calendar_visit_path(reserve_id: reserve.id, id: visit.id),
      status_class: status_class,
      inner_classes: inner_bar_classes
    )
  end
end
