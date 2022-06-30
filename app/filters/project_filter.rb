# frozen_string_literal: true

class ProjectFilter  
  DEFAULT_SORT_BY_FILTER = "submitted_recent_first"
  DEFAULT_PROJECT_TYPE_FILTER = "all"
  DEFAULT_PROJECT_STATUS_FILTER = Project::ALL_FILTER

  def initialize(filter, reserve = nil)
    @filter = filter
    @reserve = reserve
  end

  def project_search_filter
    filter&.dig(:project_search)&.strip
  end

  def sort_by_filter
    filter&.dig(:sort_by).present? ? filter&.dig(:sort_by) : DEFAULT_SORT_BY_FILTER
  end

  def reserve_filter
    filter&.dig(:reserve).nil? ? reserve&.id : filter&.dig(:reserve)
  end

  def date_range_type_filter
    filter&.dig(:date_range_type)
  end

  def project_type_filter
    filter&.dig(:project_type).present? ? filter&.dig(:project_type) : DEFAULT_PROJECT_TYPE_FILTER
  end

  def date_begin_filter
    filter&.dig(:date_begin)
  end

  def date_end_filter 
    filter&.dig(:date_end)
  end

  def project_status_filter
    filter&.dig(:project_status).present? ? filter&.dig(:project_status) : DEFAULT_PROJECT_STATUS_FILTER
  end

  def present?
    filter.present?
  end

  private
  
  attr_reader :filter, :reserve
end
