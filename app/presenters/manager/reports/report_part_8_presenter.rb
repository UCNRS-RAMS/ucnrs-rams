class Manager::Reports::ReportPart8Presenter < Manager::Reports::ReportBasePresenter
  def report_part8_data
    report_part8_data_scope
      .map{ |project| Manager::Reports::ReportPart8::ProjectPresenter.new(project: project, start_date: start_date, stop_date: stop_date,) }
      .group_by(&:institution_type)
      .each_with_object({}) do |(institution_type, projects), hash|
        hash[institution_type] = projects.group_by(&:institution_name)
      end
  end

  def fiscal_year_select_path
    :report_part_8_manager_reserve_report_path
  end

  def report_part8_data_scope
    Project
      .select("
        projects.*,
        institutions.institution_type,
        institutions.name AS institution_name
      ")
      .project_type_public_use
      .joins(:visits, owner: :institution)
      .merge(
        Visit
          .by_reserve(reserve_id)
          .with_report_access(true)
          .joins(:user_visits)
          .merge(
            UserVisit
              .having_between_time(date_start: start_date, date_end: stop_date)
              .where(status: :approved),
          )
      )
      .group(:id)
      .order(
        Institution.arel_table[:institution_type],
        Institution.arel_table[:name],
        Project.arel_table[:course_title],
      )
      .includes([:owner])
  end

  def project_user_details(project)
    UserVisit
      .joins(:visit)
      .merge(
        Visit.where(project: project),
      )
      .having_between_time(date_start: start_date, date_end: stop_date)
      .group(:role)
      .sum(:count)
  end
end
