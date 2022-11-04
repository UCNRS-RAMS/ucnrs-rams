# frozen_string_literal: true

class Manager::UsersIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  def initialize(page: 1, filter: nil)
    @page = page
    @filter = UserFilter.new(filter)
  end

  attr_reader :reserve, :page, :filter

  delegate :user_search_filter,
    :sort_by_filter,
    :user_role_filter,
    :user_institution_type_filter,
    to: :filter

  delegate :present?, to: :filter, prefix: true

  def users
    user_scope.map do |user|
      Manager::UserShowPresenter.new(user)
    end
  end

  def user_scope
    User
      .non_group_users
      .search(user_search_filter)
      .with_role(user_role_filter)
      .with_institution_type(user_institution_type_filter)
      .sort_using(sort_by_filter)
      .page(page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes(:institution)
  end

  def user_role_options
    User.roles
      .except(:no_selection)
      .map { |key, value| [I18n.t("universal.roles.#{key}"), key] }
      .unshift([I18n.t("all"), nil])
  end

  def user_institution_type_options
    Institution.institution_types
      .map { |key, value| [I18n.t("universal.institution_types.#{key}"), key] }
      .unshift([I18n.t("all"), nil])
  end

  def sort_by_options
    {
      I18n.t("manager.users.search.user_id") => :user_id,
      I18n.t("manager.users.search.last_name") => :last_name,
      I18n.t("manager.users.search.created_at") => :created_at,
    }
  end

  def show_options_class
    filter_present? ? "loadhide" : "show"
  end

  def hide_options_class
    filter_present? ? "show" : "loadhide"
  end
end
