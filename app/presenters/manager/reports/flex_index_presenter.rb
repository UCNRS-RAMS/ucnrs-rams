# frozen_string_literal: true

class Manager::Reports::FlexIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10
  FLEX_REPORT_TYPE_OPTIONS = {
    "AR Part 1: Reserve Use" => "a_r_part_1",
    "AR Part 2: User Affiliation" => "affiliation",
    "AR Part 3: Use by Instructional Groups" => "a_r_part_3",
    "Grant funding" => "funding",
    "User List by Role" => "user_list_by_role",
    "Tableau Zotero Publication Count" => "tableau_zotero_count",
    "Tableau #1,2,3 Reserve Users and User Days" => "tableau_usage",
    "Tableau #5 Faculty Count - All Institutions" => "tableau_faculty_count",
    "Tableau #6 UC Faculty-Led Reserve Use by Campus" => "tableau_uc_faculty_campus",
  }.freeze

  def initialize(reserve: nil, page: 1, filter: nil, data: nil)
    @page = page
    @reserve = reserve
    @filter = FlexReportFilter.new(filter, reserve)
    @params = filter
    @data = data
  end

  attr_reader :reserve, :page, :filter

  def html
    @params&.dig(:flex_report_type).presence || "blank"
  end

  def data
    @data
  end

  def flex_report_type_options
    FLEX_REPORT_TYPE_OPTIONS
  end

  def reserve_options
    Reserve
      .select(:id, :name)
      .order(:name)
      .each
      .inject({}) { |memo, reserve| memo.merge!(reserve.name => reserve.id) }
  end

  delegate :flex_report_type_filter,
    :reserve_filter,
    :date_begin_filter,
    :date_end_filter,
    to: :filter

  delegate :present?, to: :filter, prefix: true

  def reserve_query
    if @params&.dig(:reserve).present?
      "visits.reserve_id = #{@params&.dig(:reserve)}"
    else
      "visits.reserve_id = NULL"
    end
  end

  def start_date
    @params&.dig(:date_begin).presence
  end

  def stop_date
    @params&.dig(:date_end).presence
  end

  def project_user_details(project)
    UserVisit
      .joins(:visit)
      .merge(
        Visit.where(project: project),
      )
      .having_between_time(date_start: start_date, date_end: stop_date)
      .group(:role)
      .sum(:count)
  end
end
