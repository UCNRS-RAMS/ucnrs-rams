require "rails_helper"

RSpec.describe Manager::Visits::ReportPart1Presenter do
  let(:columns) { [ "project_type", "role", "CountUCHome", "DaysUCHome", "CountOthUS", "DaysOthUS", "CountAll", "DaysAll" ] }
  let(:rows) do
    [
      [ "Research", "Faculty", 0, 0, 2, 10, 2, 10 ],
      [ "Research", "SUBTOTAL", 0, 0, 2, 10, 2, 10 ],
      [ "TOTAL", "SUBTOTAL", 0, 0, 2, 10, 2, 10 ]
    ]
  end
  let(:report_part1_data) { ActiveRecord::Result.new(columns, rows) }
  let(:visit) { create(:visit) }

  subject(:presenter) do
    described_class.new(
      visit: visit,
      fiscal_years_spanned: [ 2024 ],
      selected_fiscal_year_ending: 2024,
      report_part1_data: report_part1_data,
    )
  end

  describe "#multiple_fiscal_years?" do
    it "is false for a single spanned fiscal year" do
      expect(presenter).not_to be_multiple_fiscal_years
    end

    context "when the visit spans more than one fiscal year" do
      subject(:presenter) do
        described_class.new(
          visit: visit,
          fiscal_years_spanned: [ 2023, 2024 ],
          selected_fiscal_year_ending: 2024,
          report_part1_data: report_part1_data,
        )
      end

      it "is true" do
        expect(presenter).to be_multiple_fiscal_years
      end

      it "lists the spanned years most-recent first" do
        expect(presenter.fiscal_year_dropdown_options).to eq([ 2024, 2023 ])
      end
    end
  end

  describe "#project_type_rows" do
    it "groups rows by project type without the grand total" do
      expect(presenter.project_type_rows.keys).to eq([ "Research" ])
    end

    context "when only the rollup total row came back" do
      let(:rows) { [ [ "TOTAL", "SUBTOTAL", nil, nil, nil, nil, nil, nil ] ] }

      it "is empty" do
        expect(presenter.project_type_rows).to be_empty
      end
    end
  end

  describe "#fiscal_year_label" do
    it "formats the selected fiscal year as a year range by default" do
      expect(presenter.fiscal_year_label).to eq("2023-2024")
    end

    it "formats an explicit fiscal year ending" do
      expect(presenter.fiscal_year_label(2020)).to eq("2019-2020")
    end
  end

  describe "#report_part1_columns" do
    it "lists the count/days columns without project_type and role" do
      expect(presenter.report_part1_columns).to eq(columns.drop(2))
    end
  end

  describe "#format_count" do
    it "renders a zero count as an em dash" do
      expect(presenter.format_count(0)).to eq("—")
    end

    it "renders a nil count as an em dash" do
      expect(presenter.format_count(nil)).to eq("—")
    end

    it "leaves a non-zero count as-is" do
      expect(presenter.format_count(4)).to eq(4)
    end
  end
end
