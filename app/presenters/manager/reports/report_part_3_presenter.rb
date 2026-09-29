class Manager::Reports::ReportPart3Presenter < Manager::Reports::ReportBasePresenter
  delegate :annual_report, to: :form, prefix: true
  delegate :fiscal_year_ending, :reserve_id, to: :form_annual_report

  def report_part3_data
    report_part3_data_scope
      .map { |project|
        Manager::Reports::ReportPart3::ProjectPresenter.new(
          project: project, start_date: start_date, stop_date: stop_date,
        )
      }
      .group_by(&:institution_type)
      .each_with_object({}) do |(institution_type, projects), hash|
        hash[institution_type] = projects.group_by(&:institution_name)
      end
  end

  def report_part3_data_scope
    Project
      .select("projects.*, institutions.institution_type, institutions.name AS institution_name")
      .of_type("class")
      .joins(owner: :institution)
      .where(id: reportable_user_visits.select(Visit.arel_table[:project_id]))
      .order(
        Institution.arel_table[:institution_type],
        Institution.arel_table[:name],
        Project.arel_table[:course_title],
      )
      .includes([:owner])
  end

  def fiscal_year_select_path
    :report_part_3_manager_reserve_report_path
  end

  def annual_report_column
    :part_3_approved
  end

  def project_user_details(project)
    reportable_user_visits
      .where(visits: { project_id: project.id })
      .group(:role)
      .sum(:count)
  end

  private

  def reportable_user_visits
    UserVisit
      .joins(:visit)
      .merge(Visit.by_reserve(reserve_id).with_report_access(true))
      .having_between_time(date_start: start_date, date_end: stop_date)
      .where(status: :approved)
  end
end
