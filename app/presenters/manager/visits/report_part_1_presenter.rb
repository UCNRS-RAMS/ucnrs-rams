class Manager::Visits::ReportPart1Presenter
  def initialize(visit:, fiscal_years_spanned:, selected_fiscal_year_ending:, report_part1_data:)
    @visit = visit
    @fiscal_years_spanned = fiscal_years_spanned
    @selected_fiscal_year_ending = selected_fiscal_year_ending
    @report_part1_data = report_part1_data
  end

  attr_reader :visit, :fiscal_years_spanned, :selected_fiscal_year_ending
  delegate :id, to: :visit, prefix: true

  def reserve_name
    visit.reserve.name
  end

  def visit_date_range
    DateRangePresenter.new(start_date: visit.starts_at, end_date: visit.ends_at)
      .value("date_range.different_years")
  end

  def project_type_rows
    @project_type_rows ||= report_part1_data
      .map { |row| Manager::Reports::ReportPart1RowPresenter.new(row) }
      .group_by { |row| row["project_type"] }
      .except("TOTAL")
  end

  def report_part1_columns
    report_part1_data.columns.excluding("project_type", "role")
  end

  def multiple_fiscal_years?
    fiscal_years_spanned.size > 1
  end

  def fiscal_year_dropdown_options
    fiscal_years_spanned.sort.reverse
  end

  def fiscal_year_label(fiscal_year_ending = selected_fiscal_year_ending)
    "#{fiscal_year_ending - 1}-#{fiscal_year_ending}"
  end

  def format_count(value)
    value.blank? || value.zero? ? "—" : value
  end

  private

  attr_reader :report_part1_data
end
