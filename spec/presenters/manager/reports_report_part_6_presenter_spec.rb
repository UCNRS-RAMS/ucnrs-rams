require "rails_helper"

RSpec.describe Manager::ReportsReportPart6Presenter do
  describe "delegations" do
    subject { Manager::ReportsReportPart6Presenter.new(report: build(:annual_report)) }
    it { is_expected.to delegate_method(:id).to(:report).with_prefix(true) }
  end

end
