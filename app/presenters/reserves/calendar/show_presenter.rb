class Reserves::Calendar::ShowPresenter < Manager::Dashboard::CalendarShowPresenter
  include Rails.application.routes.url_helpers

  def calendar_partial_name
    "calendar"
  end

  def calendar_path
    reserve_calendar_path(reserve_id: reserve)
  end

  delegate :public_calendar_access, to: :reserve

  def visits
    visit_scope.map do |visit|
      Reserves::Calendar::VisitPresenter.new(visit: visit, type: type, status: status)
    end
  end

  def visits_link_params
    CalendarBarPresenter.new(
      link_classes: visits_link_classes,
      background_classes: visits_link_background_classes,
      text_classes: "",
      text: visits_link_text,
      path: reserve_calendar_visits_path(reserve_id: reserve.id, date: current_date, status: status),
    )
  end

  private

  def visit_scope
    @visit_scope ||= reserve
      .visits
      .for_status([:approved, :in_review])
      .where(
        starts_at: ..start_date.end_of_month.end_of_week,
        ends_at: start_date.beginning_of_month.beginning_of_week..,
      )
  end
end
