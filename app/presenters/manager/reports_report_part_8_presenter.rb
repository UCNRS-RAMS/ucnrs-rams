class Manager::ReportsReportPart8Presenter
  def initialize(report:)
    @report = report
  end

  delegate :id,
  to: :report, prefix: true

  private

  def report
    AnnualReportPresenter.new(@report)
  end
end
