class Manager::Reports::ReportPart6Presenter < Manager::Reports::ReportBasePresenter
  def fiscal_year_select_path
    :report_part_6_manager_reserve_report_path
  end

  def annual_report_column
    :part_6_approved
  end
end
