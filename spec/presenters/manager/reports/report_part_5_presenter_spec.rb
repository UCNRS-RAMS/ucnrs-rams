require "rails_helper"

RSpec.describe Manager::Reports::ReportPart5Presenter do
  describe "delegations" do
    subject { Manager::Reports::ReportPart5Presenter.new(form: :form) }
    it { is_expected.to delegate_method(:zotero_url).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:zotero_login).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:zotero_password).to(:reserve).with_prefix(true) }
  end

  describe "#fiscal_year_select_path" do
    it "returns the path for the fiscal year dropdown" do
      presenter = Manager::Reports::ReportPart5Presenter.new

      fiscal_year_select_path = presenter.fiscal_year_select_path

      expect(fiscal_year_select_path).to eq :report_part_5_manager_reserve_report_path
    end
  end

  describe "#annual_report_column" do
    it "returns the annual report column to update" do
      presenter = Manager::Reports::ReportPart5Presenter.new

      annual_report_column = presenter.annual_report_column

      expect(annual_report_column).to eq :part_5_approved
    end
  end
end
