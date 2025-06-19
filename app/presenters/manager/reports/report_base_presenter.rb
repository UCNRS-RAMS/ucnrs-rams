class Manager::Reports::ReportBasePresenter
  FISCAL_MONTH_BEGIN = 7
  FISCAL_DAY_BEGIN = 1
  FISCAL_MONTH_END = 6
  FISCAL_DAY_END = 30

  def initialize(form: nil)
    @form = form
  end

  attr_reader :form

  delegate :annual_report, to: :form, prefix: true
  delegate :fiscal_year_ending, to: :form_annual_report
  delegate :reserve, to: :form_annual_report, prefix: true
  delegate :managing_campus, to: :form_annual_report_reserve, prefix: true

  def fiscal_year
    "#{fiscal_year_ending - 1}-#{fiscal_year_ending}"
  end

  def fiscal_year_ending_options
    (Date.current.year + 1).downto(2000)
      .map { |year_end| ["#{year_end - 1}-#{year_end}", year_end] }
  end

  def report_begin_date
    Date.new(fiscal_year_ending - 1, FISCAL_MONTH_BEGIN, FISCAL_DAY_BEGIN)
  end

  def report_end_date
    Date.new(fiscal_year_ending, FISCAL_MONTH_END, FISCAL_DAY_END)
  end

  def reserve_name
    form_annual_report_reserve.name
  end

  def reserve_managing_campus_name
    form_annual_report_reserve_managing_campus.name
  end

  private

  def reserve_id
    form_annual_report.reserve_id
  end

  def start_date
    Date.new(fiscal_year_ending - 1, 7, 1)
  end

  def stop_date
    Date.new(fiscal_year_ending, 6, 30)
  end
end
