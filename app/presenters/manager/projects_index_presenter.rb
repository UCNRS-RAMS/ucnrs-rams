# frozen_string_literal: true

class Manager::ProjectsIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  def initialize(reserve: nil, page: 1, filter: nil)
    @page = page
    @reserve = reserve
    @filter = ProjectFilter.new(filter, reserve)
  end

  attr_reader :reserve, :page, :filter

  def projects
    project_scope.map do |project|
      ProjectPresenter.new(project: project)
    end
  end

  def project_scope
    Project
      .with_visits_at_reserve(reserve_filter)
      .searching_term(project_search_filter)
      .of_type(project_type_filter)
      .for_status(project_status_filter)
      .having_between_time_for(
        date_range_option: date_range_type_filter&.to_sym, 
        date_start: date_begin_filter, 
        date_end: date_end_filter
      )
      .sort_using(sort_by_filter)
      .page(page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes(:applicant)
  end

  def project_status_options
    {
      "All" => Project::ALL_FILTER,
      "Open" => Project::ACTIVE_FILTER,
      "Closed" => Project::INACTIVE_FILTER,
      "Incomplete" => Project::INCOMPLETE_FILTER,
    }
  end

  def sort_by_options
    {
      I18n.t("manager.projects.index.date_submitted") => :submitted_recent_first,
      I18n.t("manager.projects.index.project_title") => :sort_by_project_title,
      I18n.t("manager.projects.index.owner_last_name") => :sort_by_owner_last_name,
    }
  end

  def project_type_options
    {
      "All" => :all,
      "Research" => :research,
      "University Class" => :university_class,
      "Meeting or Conference" => :meeting_or_conference,
      "Public Use" => :public_use,
    }
  end

  def show_date_range_options
    {
      I18n.t("manager.projects.index.date_project_submitted") => :project_submitted_date_range,
      I18n.t("manager.projects.index.project_date_range") => :project_date_range,
      I18n.t("manager.projects.index.visit_date_range") => :visit_date_range,
      I18n.t("manager.projects.index.invoice_created_at_date_range") => :invoice_created_at_date_range,
    }
  end

  def reserve_options
    Reserve
      .select(:id, :name)
      .order(:name)
      .each
      .inject({ "All" => nil }) { |memo, reserve| memo.merge!(reserve.name => reserve.id) }
  end

  delegate :project_search_filter,
    :sort_by_filter,
    :reserve_filter,
    :date_range_type_filter,
    :project_type_filter,
    :date_begin_filter,
    :date_end_filter ,
    :project_status_filter,
    to: :filter

  delegate :present?, to: :filter, prefix: true
end
