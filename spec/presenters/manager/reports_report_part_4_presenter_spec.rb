require "rails_helper"

RSpec.describe Manager::ReportsReportPart4Presenter do
  describe "delegations" do
    subject { Manager::ReportsReportPart4Presenter.new(report: build(:annual_report)) }
    it { is_expected.to delegate_method(:fiscal_year_ending).to(:report) }
  end

end
