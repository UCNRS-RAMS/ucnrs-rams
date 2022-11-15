# frozen_string_literal: true

class InstitutionFilter
  DEFAULT_INSTITUTION_SORT_BY_FILTER = :user_id
  DEFAULT_INSTITUTION_COUNTRY_FILTER = nil
  DEFAULT_INSTITUTION_TYPE_FILTER = nil

  def initialize(filter = nil)
    @filter = filter
  end

  delegate :present?, to: :filter

  def institution_search_filter
    filter&.dig(:institution_search).present? ? filter&.dig(:institution_search)&.strip : ""
  end

  def institution_sort_by_filter
    filter&.dig(:institution_sort_by).presence || DEFAULT_INSTITUTION_SORT_BY_FILTER
  end

  def institution_country_filter
    filter&.dig(:institution_country).presence || DEFAULT_INSTITUTION_COUNTRY_FILTER
  end

  def institution_type_filter
    filter&.dig(:institution_type).presence || DEFAULT_INSTITUTION_TYPE_FILTER
  end

  private

  attr_reader :filter
end
