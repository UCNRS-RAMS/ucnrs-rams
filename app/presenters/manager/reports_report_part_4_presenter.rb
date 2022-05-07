class Manager::ReportsReportPart4Presenter
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
