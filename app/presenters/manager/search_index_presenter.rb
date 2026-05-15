# frozen_string_literal: true

class Manager::SearchIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  def initialize(reserve: nil, page: 1, filter: nil)
    @page = page
    @reserve = reserve
    @filter = filter
  end

  attr_reader :reserve, :page, :filter

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    @visit_scope ||= Visit
      .by_reserve(reserve)
      .of_project_type(filter&.dig(:visit_project_type))
      .with_report_access(filter&.dig(:report_access))
      .having_visitor_with_institution_name(filter&.dig(:institution_name))
      .having_visitor_with_institution_type(institution_type)
      .having_visitor_with_institution_id(institution_id)
      .having_visitor_without_institution_id(without_institution_id)
      .having_visitor_with_user_type(filter&.dig(:user_type))
      .having_visitor_between_dates(
        date_begin: filter&.dig(:date_begin),
        date_end: filter&.dig(:date_end),
      )
      .having_visitor_with_status(filter&.dig(:visit_status))
      .group(:id)
      .page(page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes([:reserve, :user, :project])
  end

  def institution_type
    integer_string?(filter&.dig(:institution_type)) ? nil : filter&.dig(:institution_type)
  end

  def institution_id
    integer_string?(filter&.dig(:institution_type)) ? filter&.dig(:institution_type).to_i : nil
  end

  def without_institution_id
    filter&.dig(:exclude_reserve_institution).present? ? reserve.managing_campus.id : nil
  end

  def visit_status_options
    Visit
      .statuses
      .inject({ I18n.t("all") => nil }) do |memo, (key, _value)|
        memo.merge!(I18n.t("universal.visit.statuses.#{key}") => key)
      end
  end

  def visit_project_type_options
    Project
      .project_types
      .inject({ I18n.t("all") => nil }) do |memo, (key, _value)|
        memo.merge!(I18n.t("universal.project.project_types_formal.#{key}") => key)
      end
  end

  def sort_by_options
    {
      I18n.t("manager.dashboard.visits.index.date_submitted") => :submitted_recent_first,
      I18n.t("manager.dashboard.visits.index.visit_start_date") => :recent_start_date_first,
    }
  end

  def reserve_options
    Reserve
      .select(:id, :name)
      .order(:name)
      .inject({ I18n.t("all") => nil }) { |memo, reserve| memo.merge!(reserve.name => reserve.id) }
  end

  def report_access_options
    {
      I18n.t("all") => nil,
      I18n.t("enabled") => true,
      I18n.t("disabled") => false,
    }
  end

  def user_type_options
    User
      .roles
      .inject({ I18n.t("all") => nil }) do |memo, (key, _value)|
        memo.merge!(I18n.t("universal.roles.#{key}") => key)
      end
  end

  def institution_type_options
    Institution
      .institution_types
      .inject(
        {
          I18n.t("all") => nil,
          reserve.managing_campus.name => reserve.managing_campus.id,
        },
      ) do |memo, (key, _value)|
        memo.merge!(I18n.t("universal.institution_types.#{key}") => key)
      end
  end

  def integer_string?(str)
    str.is_a?(String) && /\A[+-]?\d+\z/.match?(str)
  end
end
