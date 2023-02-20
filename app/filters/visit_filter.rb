# frozen_string_literal: true

class VisitFilter  
  DEFAULT_SORT_BY_FILTER = "submitted_recent_first"
  DEFAULT_VISIT_PROJECT_TYPE_FILTER = nil
  DEFAULT_VISIT_STATUS_FILTER = nil
  DEFAULT_REPORT_ACCESS_FILTER = nil
  DEFAULT_AMENITY_FILTER = "all"

  def initialize(filter, reserve = nil)
    @filter = filter
    @reserve = reserve
  end

  def visit_search_filter
    filter&.dig(:visit_search)&.strip
  end

  def sort_by_filter
    filter&.dig(:sort_by).presence || DEFAULT_SORT_BY_FILTER
  end

  def reserve_filter
    filter&.dig(:reserve) || reserve&.id
  end

  def amenity_filter
    if Amenity.where(id: (filter&.dig(:amenity)), reserve_id: reserve_filter).present?
      filter&.dig(:amenity)
    else
      DEFAULT_AMENITY_FILTER
    end
  end

  def date_range_type_filter
    filter&.dig(:date_range_type)
  end

  def visit_project_type_filter
    filter&.dig(:visit_project_type).presence || DEFAULT_VISIT_PROJECT_TYPE_FILTER
  end

  def date_begin_filter
    filter&.dig(:date_begin)
  end

  def date_end_filter 
    filter&.dig(:date_end)
  end

  def visit_status_filter
    filter&.dig(:visit_status).presence || DEFAULT_VISIT_STATUS_FILTER
  end

  def report_access_filter
    if filter&.dig(:report_access).present?
      ActiveModel::Type::Boolean.new.cast(filter&.dig(:report_access))
    else
      DEFAULT_REPORT_ACCESS_FILTER
    end
  end

  def present?
    filter.present?
  end

  private

  attr_reader :filter, :reserve
end
