class Manager::Reports::ReportPart2Presenter < Manager::Reports::ReportBasePresenter
  def report_part2_data
    report_part2_data_scope
      .map{ |institution| InstitutionPresenter.new(institution) }
      .group_by(&:institution_type)
  end

  def fiscal_year_select_path
    :report_part_2_manager_reserve_report_path
  end

  def annual_report_column
    :part_2_approved
  end

  def report_part2_data_scope
    Institution
      .joins(:user_visits)
      .merge(
        UserVisit
          .at_reserve(form_annual_report_reserve)
          .approved_status
          .having_between_time(date_start: start_date, date_end: stop_date)
          .joins(:visit)
          .merge(
            Visit.where(report_access: true),
          )
      )
      .group(:id)
      .order(:institution_type, :name)
      .includes([:state, :country])
  end
end
