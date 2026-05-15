# frozen_string_literal: true

class UserFilter
  DEFAULT_SORT_BY_FILTER = :user_id
  DEFAULT_USER_ROLE_FILTER = nil
  DEFAULT_USER_INSTITUTION_TYPE_FILTER = nil

  def initialize(filter = nil)
    @filter = filter
  end

  def user_search_filter
    filter&.dig(:user_search).present? ? filter&.dig(:user_search)&.strip : ""
  end

  def sort_by_filter
    filter&.dig(:sort_by).presence || DEFAULT_SORT_BY_FILTER
  end

  def user_role_filter
    filter&.dig(:user_role).presence || DEFAULT_USER_ROLE_FILTER
  end

  def user_institution_type_filter
    filter&.dig(:user_institution_type).presence || DEFAULT_USER_INSTITUTION_TYPE_FILTER
  end

  delegate :present?, to: :filter

  private

  attr_reader :filter
end
