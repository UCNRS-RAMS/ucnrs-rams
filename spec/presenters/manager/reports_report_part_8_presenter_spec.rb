require "rails_helper"

RSpec.describe Manager::ReportsReportPart8Presenter do
  describe "delegations" do
    subject { Manager::ReportsReportPart8Presenter.new(report: build(:annual_report)) }
    it { is_expected.to delegate_method(:fiscal_year_ending).to(:report) }
  end

end
