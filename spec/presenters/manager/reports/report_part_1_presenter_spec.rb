require "rails_helper"

RSpec.describe Manager::Reports::ReportPart1Presenter do
  describe "delegations" do
    subject { Manager::Reports::ReportPart1Presenter.new(form: :form) }
    it { is_expected.to delegate_method(:annual_report).to(:form).with_prefix(true) }
    it { is_expected.to delegate_method(:fiscal_year_ending).to(:form_annual_report) }
  end

  describe "#report_part1" do
    it "group report part 1 data by 'project_type'" do
      report_part1_data = [
        {'project_type' => 'one', 'data' => 1},
        {'project_type' => 'two', 'data' => 2},
      ]
      presenter = Manager::Reports::ReportPart1Presenter.new(report_part1_data: report_part1_data)

      result = presenter.report_part1

      expect(result["one"]).to all(be_a(Manager::Reports::ReportPart1RowPresenter))
      expect(result["two"]).to all(be_a(Manager::Reports::ReportPart1RowPresenter))
      expect(result["one"][0]['data']).to eq 1
      expect(result["two"][0]['data']).to eq 2
    end
  end

  describe "#row_total" do
    it "returns the first array from the key of 'TOTAL'" do
      report_part1_data = [
        {'project_type' => 'one', 'data' => 1},
        {'project_type' => 'TOTAL', 'data' => 1},
      ]
      presenter = Manager::Reports::ReportPart1Presenter.new(report_part1_data: report_part1_data)

      result = presenter.row_total

      expect(result["data"]).to eq 1
    end
  end

  describe "#report_part1_columns" do
    it "return the columns without 'project_type' and 'role'" do
      report_part1_data = double(ActiveRecord::Result)
      allow(report_part1_data).to receive(:columns).and_return(
        ['one', 'two', 'project_type', 'three', 'role']
      )
      presenter = Manager::Reports::ReportPart1Presenter.new(report_part1_data: report_part1_data)

      result = presenter.report_part1_columns

      expect(result).to match_array ['one', 'two', 'three']
    end
  end

  describe "#fiscal_year" do
    it "is the form fiscal year" do
      annual_report = create(:annual_report, fiscal_year_ending: 2049)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart1Presenter.new(form: form)

      fiscal_year = presenter.fiscal_year

      expect(fiscal_year).to eq "2048-2049"
    end
  end

  describe "#fiscal_year_ending_options" do
    it "is an array of fiscal year options" do
      fiscal_year_options = [].tap do |arr|
        (2000..(Date.current.year + 1)).each { |year_end| arr << ["#{year_end - 1}-#{year_end}", year_end] }
      end
      presenter = Manager::Reports::ReportPart1Presenter.new

      fiscal_year_ending_options = presenter.fiscal_year_ending_options

      expect(fiscal_year_ending_options).to match_array fiscal_year_options
    end
  end
end
