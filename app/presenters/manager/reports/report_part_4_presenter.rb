class Manager::Reports::ReportPart4Presenter < Manager::Reports::ReportBasePresenter
  def report_part4_data
    report_part4_data_scope
      .map{ |project| ProjectPresenter.new(project: project) }
  end

  def fiscal_year_select_path
    :report_part_4_manager_reserve_report_path
  end

  def annual_report_column
    :part_4_approved
  end

  def report_part4_data_scope
    Project
      .of_type(:research)
      .joins(:visits)
      .merge(
        Visit
          .by_reserve(reserve_id)
          .for_status(:approved)
          .where(report_access: true)
          .joins(:user_visits)
          .merge(
            UserVisit
              .approved_status
              .having_between_time(date_start: start_date, date_end: stop_date),
          )
      )
      .group(:id)
      .includes(team_memberships: :user)
  end
end
