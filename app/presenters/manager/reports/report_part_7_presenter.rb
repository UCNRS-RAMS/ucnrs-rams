class Manager::Reports::ReportPart7Presenter < Manager::Reports::ReportBasePresenter
  def fiscal_year_select_path
    :report_part_7_manager_reserve_report_path
  end

  def annual_report_column
    :part_7_approved
  end
end
