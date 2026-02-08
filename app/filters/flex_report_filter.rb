# frozen_string_literal: true

class FlexReportFilter
  DEFAULT_FLEX_REPORT_TYPE = nil

  def initialize(filter, reserve = nil)
    @filter = filter
    @reserve = reserve
  end

  def flex_report_type_filter
    filter&.dig(:flex_report_type).presence || DEFAULT_FLEX_REPORT_TYPE
  end

  def reserve_filter
    filter&.dig(:reserve) || reserve&.id
  end

  def date_begin_filter
    filter&.dig(:date_begin)
  end

  def date_end_filter
    filter&.dig(:date_end)
  end

  def present?
    filter.present?
  end

  private

  attr_reader :filter, :reserve
end
