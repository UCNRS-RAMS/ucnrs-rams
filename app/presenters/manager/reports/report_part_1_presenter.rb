class Manager::Reports::ReportPart1Presenter
  def initialize(form: nil, report_part1_data: nil)
    @form = form
    @report_part1_data = report_part1_data
  end

  delegate :annual_report, to: :form, prefix: true

  delegate :fiscal_year_ending, to: :form_annual_report

  def report_part1
    @report_part1 ||= report_part1_data
      .map{ |row| Manager::Reports::ReportPart1RowPresenter.new(row) }
      .group_by { |row| row["project_type"] }
  end

  def row_total
    report_part1["TOTAL"]&.first
  end

  def report_part1_columns
    report_part1_data.columns.excluding("project_type", "role")
  end

  def fiscal_year
    "#{fiscal_year_ending - 1}-#{fiscal_year_ending}"
  end

  def fiscal_year_ending_options
    (2000..(Date.current.year + 1)).map { |year_end| ["#{year_end - 1}-#{year_end}", year_end] }
  end

  attr_reader :report_part1_data, :form
end
