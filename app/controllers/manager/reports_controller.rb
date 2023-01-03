class Manager::ReportsController < ApplicationController
  include ReportQueries

  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  FISCAL_MONTH_BEGIN = 7
  FISCAL_DAY_BEGIN = 1
  FISCAL_MONTH_END = 6
  FISCAL_DAY_END = 30

  def report_part_1
    form = AnnualReportForm.new(annual_report: annual_report)
    @presenter = Manager::Reports::ReportPart1Presenter.new(
      form: form,
      report_part1_data: query_part_1(current_reserve, report_start_date, report_stop_date)
    )
  end

  def report_part_2
    form = AnnualReportForm.new(annual_report: annual_report)
    @presenter = Manager::Reports::ReportPart2Presenter.new(
      form: form,
      reserve: current_reserve,
    )
  end

  def report_part_3
    form = AnnualReportForm.new(annual_report: annual_report)
    @presenter = Manager::Reports::ReportPart3Presenter.new(
      form: form,
    )
  end

  def report_part_4
    form = AnnualReportForm.new(annual_report: annual_report)
    @presenter = Manager::Reports::ReportPart4Presenter.new(
      form: form,
    )
  end

  def report_part_5
    @presenter = Manager::ReportsReportPart5Presenter.new(
      report: annual_report,
    )
  end

  def report_part_6
    @presenter = Manager::ReportsReportPart6Presenter.new(
      report: annual_report,
    )
  end

  def report_part_7
    @presenter = Manager::ReportsReportPart7Presenter.new(
      report: annual_report,
    )
  end

  def report_part_8
    @presenter = Manager::ReportsReportPart8Presenter.new(
      report: annual_report,
    )
  end

  def update
    form = AnnualReportForm.new(annual_report: annual_report, params: report_params)

    if form.save
      flash[:notice] = t(".flash.report_updated_success")
    else
      flash[:alert] = t(".flash.cannot_update_report")
    end

    redirect_back fallback_location: manager_reserve_report_path(current_reserve, annual_report.fiscal_year_ending)
  end

  private

  def annual_report
    AnnualReport.where(reserve: current_reserve, fiscal_year_ending: fiscal_year_end).first_or_initialize
  end

  def fiscal_year_end
    params[:id].to_i || Date.current.year
  end

  def report_start_date
    Date.new(fiscal_year_end - 1, FISCAL_MONTH_BEGIN, FISCAL_DAY_BEGIN)
  end

  def report_stop_date
    Date.new(fiscal_year_end, FISCAL_MONTH_END, FISCAL_DAY_END)
  end

  def report_params
    params.require(:annual_report).permit(
      :part_5_publications,
      :part_6_narrative,
      :part_7_campus_committee,
      :part_1_approved,
      :part_2_approved,
      :part_3_approved,
      :part_4_approved,
      :part_5_approved,
      :part_6_approved,
      :part_7_approved,
      :part_6_narrative_file,
    )
  end
end
