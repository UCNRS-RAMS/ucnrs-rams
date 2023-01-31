require "rails_helper"

RSpec.describe Manager::Reports::ReportPart6Presenter do
  describe "#fiscal_year_select_path" do
    it "returns the path for the fiscal year dropdown" do
      presenter = Manager::Reports::ReportPart6Presenter.new

      fiscal_year_select_path = presenter.fiscal_year_select_path

      expect(fiscal_year_select_path).to eq :report_part_6_manager_reserve_report_path
    end
  end

  describe "#annual_report_column" do
    it "returns the annual report column to update" do
      presenter = Manager::Reports::ReportPart6Presenter.new

      annual_report_column = presenter.annual_report_column

      expect(annual_report_column).to eq :part_6_approved
    end
  end
end
