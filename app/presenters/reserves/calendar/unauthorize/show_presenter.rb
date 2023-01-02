class Reserves::Calendar::Unauthorize::ShowPresenter < Home::CalendarShowPresenter

  def initialize(current_reserve:, start_date: nil, user:)
    super(start_date: start_date, user: user)
    @current_reserve = current_reserve
  end

  attr_reader :current_reserve

  def calendar_partial_name
    "reserves/calendar/unauthorize/calendar"
  end

  def reserve_list
    Reserve.all.map { |x| [x.short_name, x.id] }
  end

  def reserve_selected(option)
    option == "#{current_reserve.id}" ? "selected" : ""
  end

  def calendar_path
    reserve_calendar_path(reserve_id: current_reserve)
  end

  private

  def visit_scope
    Visit
      .approved
      .by_reserve(current_reserve)
      .where(
        starts_at: ..start_date.end_of_month.end_of_week,
        ends_at: start_date.beginning_of_month.beginning_of_week..,
      )
  end

  def hidden_link_params
    Reserves::Calendar::Unauthorize::BarPresenter.new(
      link_classes: "disable-link",
      background_classes: "border",
      text_classes: "",
      text: "Dummay bar",
      path: "#",
    )
  end

  def visits
    visit_scope.map do |visit|
      Reserves::Calendar::Unauthorize::VisitPresenter.new(visit: visit)
    end
  end
end
