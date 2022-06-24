# frozen_string_literal: true
DEFAULT_LIMIT_FOR_INDEX = 10

class Manager::ProjectsIndexPresenter
  def initialize(reserve:, page: 1)
    @page = page
    @reserve = reserve
  end

  attr_reader :reserve, :page

  def projects
    project_scope.map do |project|
      ProjectPresenter.new(project: project)
    end
  end

  def project_scope
    Project
      .with_visits_at_reserve(reserve)
      .submitted_recent_first
      .page(page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes(:applicant)
  end

  def show_options
    {
      I18n.t("manager.projects.index.all") => :all
    }
  end

  def sort_by_options
    {
      I18n.t("manager.projects.index.date_submitted") => :date_submitted,
      I18n.t("manager.projects.index.project_title") => :project_title,
      I18n.t("manager.projects.index.owner_last_name") => :owner_last_name,
    }
  end

  def project_type_options
    Project.project_types.map {|key, value| [value, key]}
  end

  def show_date_range_options
    {
      I18n.t("manager.projects.index.date_project_submitted") => :date_project_submitted,
      I18n.t("manager.projects.index.project_date_range") => :project_date_range,
      I18n.t("manager.projects.index.visit_date_range") => :visit_date_range,
      I18n.t("manager.projects.index.invoice_created_at_date_range") => :invoice_created_at_date_range,
    }
  end

  def reserve_options
    Reserve.select(:id, :name).find_each.inject({}) { |memo, reserve| memo.merge!(reserve.name => reserve.id) }
  end
end
