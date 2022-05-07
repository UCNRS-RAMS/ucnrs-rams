require "rails_helper"

RSpec.describe Manager::ReportsReportPart7Presenter do
  describe "delegations" do
    subject { Manager::ReportsReportPart7Presenter.new(report: build(:annual_report)) }
    it { is_expected.to delegate_method(:id).to(:report).with_prefix(true) }
  end

end
