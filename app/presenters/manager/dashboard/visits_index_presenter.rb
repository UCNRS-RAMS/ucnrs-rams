# frozen_string_literal: true

class Manager::Dashboard::VisitsIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  def initialize(reserve: nil, page: 1, filter: nil)
    @page = page
    @reserve = reserve
    @filter = VisitFilter.new(filter, reserve)
  end

  attr_reader :reserve, :page, :filter

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    Visit
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

  def visit_status_options
    Visit
      .statuses
      .inject({ "All" => nil }) do |memo, (key, value)| 
        memo.merge!( I18n.t("universal.visit.statuses.#{key}") => key)
      end
  end

  def visit_project_type_options
    Project
      .project_types
      .inject({ "All" => nil }) do |memo, (key, value)| 
        memo.merge!( I18n.t("universal.project.project_types.#{key}") => key)
      end
  end

  def sort_by_options
    {
      I18n.t("manager.dashboard.visits.index.date_submitted") => :submitted_recent_first,
      I18n.t("manager.dashboard.visits.index.visit_start_date") => :recent_start_date_first,
    }
  end

  def reserve_options
    Reserve
      .select(:id, :name)
      .order(:name)
      .inject({ "All" => nil }) { |memo, reserve| memo.merge!(reserve.name => reserve.id) }
  end

  def report_access_options
    {
      I18n.t("enabled") => true,
      I18n.t("disabled") => false,
    }
  end

  def amenity_options
    if ApplicationRecord::NUMERIC_SEARCH_PATTERN === reserve_filter.to_s
      Amenity
        .select(:title, :id)
        .where(reserve: reserve_filter)
        .visible
        .in_sort_order
        .inject({ "All" => "all" }) { |memo, amenity| memo.merge!(amenity.title => amenity.id) }
    else
      { "All" => "all" }
    end
  end

  delegate :visit_search_filter,
    :sort_by_filter,
    :reserve_filter,
    :amenity_filter,
    :date_range_type_filter,
    :visit_project_type_filter,
    :date_begin_filter,
    :date_end_filter ,
    :visit_status_filter,
    :report_access_filter,
    to: :filter

  delegate :present?, to: :filter, prefix: true
end
