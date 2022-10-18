class Manager::ReportsReportPart7Presenter
  def initialize(report:)
    @report = report
  end

  delegate :fiscal_year_ending, to: :report

  private
  
  attr_reader :report
end
