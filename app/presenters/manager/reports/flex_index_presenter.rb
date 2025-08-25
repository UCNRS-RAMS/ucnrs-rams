# frozen_string_literal: true

class Manager::Reports::FlexIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  def initialize(reserve: nil, page: 1, filter: nil, data: nil)
    @page = page
    @reserve = reserve
    @filter = ProjectFilter.new(filter, reserve)
    @params = filter
    @data = data
  end

  attr_reader :reserve, :page, :filter

  def html
    @params&.dig(:project_status) || "blank"
  end

  def data
    @data
  end

  def project_status_options
    {
      "Grant funding" => "funding",
      "Tableau #1,2,3 Reserve Users and User Days" => "tableau_usage",
      "Tableau #5 Faculty Count - All Institutions" => "tableau_faculty_count",
      "Tableau #6 UC Faculty-Led Reserve Use by Campus" => "tableau_uc_faculty_campus",
    }
  end

  def reserve_options
    Reserve
      .select(:id, :name)
      .order(:name)
      .each
      .inject({}) { |memo, reserve| memo.merge!(reserve.name => reserve.id) }
  end

  delegate :project_search_filter,
    :sort_by_filter,
    :reserve_filter,
    :date_range_type_filter,
    :project_type_filter,
    :date_begin_filter,
    :date_end_filter,
    :project_status_filter,
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
end
