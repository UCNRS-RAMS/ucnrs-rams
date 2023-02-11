class Manager::Reports::ReportPart5Presenter < Manager::Reports::ReportBasePresenter
  delegate :zotero_url,
    :zotero_login,
    :zotero_password,
    to: :reserve, prefix: true

  def fiscal_year_select_path
    :report_part_5_manager_reserve_report_path
  end

  def annual_report_column
    :part_5_approved
  end

  private

  def reserve
    reserve ||= Reserve.find reserve_id
  end
end
