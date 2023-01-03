class Manager::Reports::ReportBasePresenter
  def initialize(form: nil)
    @form = form
  end

  attr_reader :form

  delegate :annual_report, to: :form, prefix: true
  delegate :fiscal_year_ending, to: :form_annual_report

  def fiscal_year
    "#{fiscal_year_ending - 1}-#{fiscal_year_ending}"
  end

  def fiscal_year_ending_options
    (2000..(Date.current.year + 1))
      .map { |year_end| ["#{year_end - 1}-#{year_end}", year_end] }
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
