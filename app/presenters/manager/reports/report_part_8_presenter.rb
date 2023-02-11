class Manager::Reports::ReportPart8Presenter < Manager::Reports::ReportBasePresenter
  def report_part8_data
    report_part8_data_scope
      .map{ |project| Manager::Reports::ReportPart8::ProjectPresenter.new(project) }
      .group_by(&:institution_type)
  end

  def fiscal_year_select_path
    :report_part_8_manager_reserve_report_path
  end

  def report_part8_data_scope
    Project
      .select("projects.*, institutions.institution_type, institutions.name AS institution_name")
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
              .where(status: :approved)
          )
      )
      .group(:id)
      .order(
        Institution.arel_table[:institution_type],
        Institution.arel_table[:name],
        Project.arel_table[:course_title]
      )
      .includes([:owner])
  end
end
