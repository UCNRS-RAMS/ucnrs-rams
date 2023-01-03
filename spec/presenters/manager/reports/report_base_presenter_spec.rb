require "rails_helper"

RSpec.describe Manager::Reports::ReportBasePresenter do
  describe "delegations" do
    subject { Manager::Reports::ReportBasePresenter.new(form: :form) }
    it { is_expected.to delegate_method(:annual_report).to(:form).with_prefix(true) }
    it { is_expected.to delegate_method(:fiscal_year_ending).to(:form_annual_report) }
  end

  describe "#fiscal_year" do
    it "is the form fiscal year" do
      annual_report = create(:annual_report, fiscal_year_ending: 2049)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportBasePresenter.new(form: form)

      fiscal_year = presenter.fiscal_year

      expect(fiscal_year).to eq "2048-2049"
    end
  end

  describe "#fiscal_year_ending_options" do
    it "is an array of fiscal year options" do
      fiscal_year_options = (2000..(Date.current.year + 1))
        .map { |year_end| ["#{year_end - 1}-#{year_end}", year_end] }
      presenter = Manager::Reports::ReportBasePresenter.new(form: :form)

      fiscal_year_ending_options = presenter.fiscal_year_ending_options

      expect(fiscal_year_ending_options).to match_array fiscal_year_options
    end
  end
end
