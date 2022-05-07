class Manager::ReportsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!

  def report_part_1
    @presenter = Manager::ReportsReportPart1Presenter.new(
      report: report,
    )
  end

  def report_part_2
    @presenter = Manager::ReportsReportPart2Presenter.new(
      report: report,
    )
  end

  def report_part_3
    @presenter = Manager::ReportsReportPart3Presenter.new(
      report: report,
    )
  end

  def report_part_4
    @presenter = Manager::ReportsReportPart4Presenter.new(
      report: report,
    )
  end

  def report_part_5
    @presenter = Manager::ReportsReportPart5Presenter.new(
      report: report,
    )
  end

  def report_part_6
    @presenter = Manager::ReportsReportPart6Presenter.new(
      report: report,
    )
  end

  def report_part_7
    @presenter = Manager::ReportsReportPart7Presenter.new(
      report: report,
    )
  end

  def report_part_8
    @presenter = Manager::ReportsReportPart8Presenter.new(
      report: report,
    )
  end

  private

  def report
    AnnualReport.where(fiscal_year_ending: year).first
  end

  def year
    params[:id] || Date.current.year
  end
end
