# frozen_string_literal: true

class Reserves::Calendar::VisitsIndexPresenter < Manager::Dashboard::VisitsIndexPresenter

  def visits
    visit_scope.map do |visit|
      Reserves::Calendar::VisitPresenter.new(visit: visit)
    end
  end

  def visit_scope
    Visit
      .for_status([:approved, :in_review])
      .by_reserve(reserve_filter)
      .searching_term(visit_search_filter)
      .of_project_type(visit_project_type_filter)
      .with_report_access(report_access_filter)
      .using_amenity(amenity_filter)
      .sort_using(sort_by_filter)
      .having_between_time_for(
        date_range_option: :visit_date_range,
        date_start: date_begin_filter,
        date_end: date_end_filter
      )
      .for_status(visit_status_filter)
      .page(page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes([:reserve, :user])
  end
end
