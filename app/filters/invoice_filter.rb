# frozen_string_literal: true

class InvoiceFilter
  DEFAULT_SORT_BY_FILTER = "created_recent_first"
  DEFAULT_INVOICE_STATUS_FILTER = "all"

  def initialize(filter, reserve = nil)
    @filter = filter
    @reserve = reserve
  end

  def invoice_search_filter
    filter&.dig(:invoice_search)&.strip
  end

  def sort_by_filter
    filter&.dig(:sort_by).present? ? filter&.dig(:sort_by) : DEFAULT_SORT_BY_FILTER
  end

  def reserve_filter
    filter&.dig(:reserve).nil? ? reserve&.id : filter&.dig(:reserve)
  end

  def invoice_date_begin_filter
    filter&.dig(:invoice_date_begin)
  end

  def invoice_date_end_filter
    filter&.dig(:invoice_date_end)
  end

  def visit_date_begin_filter
    filter&.dig(:visit_date_begin)
  end

  def visit_date_end_filter
    filter&.dig(:visit_date_end)
  end

  def invoice_status_filter
    filter&.dig(:invoice_status).present? ? filter&.dig(:invoice_status) : DEFAULT_INVOICE_STATUS_FILTER
  end

  def present?
    filter.present?
  end

  private
  
  attr_reader :filter, :reserve
end
