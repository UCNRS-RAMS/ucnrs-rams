# frozen_string_literal: true

require "rails_helper"

RSpec.describe AnnualReportForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:annual_report) }
    it { is_expected.to delegate_method(:validate).to(:annual_report) }
    it { is_expected.to delegate_method(:errors).to(:annual_report) }
    it { is_expected.to delegate_missing_methods_to(:annual_report) }
  end

  describe "initializing" do
    it "makes a new empty AnnualReportForm" do
      form = AnnualReportForm.new

      expect(form).to have_attributes(
        id: nil,
        reserve_id: nil,
        fiscal_year_ending: nil,
        year_old: nil,
        part_5_publications: nil,
        part_6_narrative: nil,
        part_7_campus_committee: nil,
        part_1_approved: false,
        part_2_approved: false,
        part_3_approved: false,
        part_4_approved: false,
        part_5_approved: false,
        part_6_approved: false,
        part_7_approved: false,
      )
    end

    it "makes a new AnnualReportForm from params" do
      params = {
        id: 10,
        reserve_id: 11,
        fiscal_year_ending: 2000,
        year_old: "2000-2001",
        part_5_publications: "pubs",
        part_6_narrative: "narrative",
        part_7_campus_committee: "committee",
        part_1_approved: true,
        part_2_approved: true,
        part_3_approved: true,
        part_4_approved: true,
        part_5_approved: true,
        part_6_approved: true,
        part_7_approved: true,
      }
      form = AnnualReportForm.new(params: params)

      expect(form).to have_attributes(
        id: 10,
        reserve_id: 11,
        fiscal_year_ending: 2000,
        year_old: "2000-2001",
        part_5_publications: "pubs",
        part_6_narrative: "narrative",
        part_7_campus_committee: "committee",
        part_1_approved: true,
        part_2_approved: true,
        part_3_approved: true,
        part_4_approved: true,
        part_5_approved: true,
        part_6_approved: true,
        part_7_approved: true,
      )
    end

    it "loads an existing annual_report into AnnualReportForm from given annual_report" do
      annual_report = create(:annual_report, part_6_narrative: "narrative 1")
      form = AnnualReportForm.new(annual_report: annual_report)

      expect(form).to have_attributes(id: annual_report.id, part_6_narrative: "narrative 1")
    end

    context "when an annual_report and params is given" do
      it "overwrites the given annual_report attributes with the given params" do
        annual_report = create(:annual_report, part_6_narrative: "narrative old")
        form = AnnualReportForm.new(annual_report: annual_report, params: { part_6_narrative: "narrative new" })

        expect(form).to have_attributes(id: annual_report.id, part_6_narrative: "narrative new")
      end
    end
  end

  describe "#save" do
    it "saves the annual_report if there are no errors" do
      annual_report = create(:annual_report, part_6_narrative: "narrative old")
      form = AnnualReportForm.new(annual_report: annual_report, params: { part_6_narrative: "narrative new" })

      result = form.save

      expect(result).to be_truthy
      expect(form.annual_report).to be_persisted
      expect(form.annual_report).to have_attributes(id: annual_report.id, part_6_narrative: "narrative new")
    end

    it "makes sure errors are visible when save fails" do
      form = AnnualReportForm.new()

      result = form.save

      expect(result).to be_falsy
      expect(form.annual_report).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
