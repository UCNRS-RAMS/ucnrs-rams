# frozen_string_literal: true

class Manager::Reports::FlexIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  def initialize(reserve: nil, page: 1, filter: nil)
    @page = page
    @reserve = reserve
    @filter = ProjectFilter.new(filter, reserve)
    @params = filter
  end

  attr_reader :reserve, :page, :filter

  def funding_scope
    Funding
      .select("fundings.*, visits.reserve_id")
      .left_outer_joins(project: [visits: :user_visits])
      .where(
        "#{reserve_query}
        AND user_visits.arrives_at >= :start_date
        AND user_visits.departs_at <= :stop_date
        AND user_visits.status = 'Approved'
        AND projects.project_type = 'Research'
        AND projects.AnnualReportAccess = 1
        AND projects.status IN ('Open', 'Closed')",
        { start_date: start_date, stop_date: stop_date },
      )
      .includes(:project)
      .group(:id)
      .order("visits.reserve_id")
  end

  def project_status_options
    {
      "Grant funding" => "funding",
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
