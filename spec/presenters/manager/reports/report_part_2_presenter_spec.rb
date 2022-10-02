require "rails_helper"

RSpec.describe Manager::Reports::ReportPart2Presenter do
  describe "delegations" do
    subject { Manager::Reports::ReportPart2Presenter.new(form: :form) }
    it { is_expected.to delegate_method(:annual_report).to(:form).with_prefix(true) }
    it { is_expected.to delegate_method(:fiscal_year_ending).to(:form_annual_report) }
  end

  describe "#report_part2_data" do
    it "group report part 2 data by 'project_type'" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve1_visit = create(:visit,
        reserve: reserve1, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      reserve2_visit = create(:visit,
        reserve: reserve2, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      no_report_access_visit = create(:visit, report_access: false)
      uc_type_institution1 = create(:institution, institution_type: :university_of_california)
      uc_type_institution2 = create(:institution, institution_type: :university_of_california)
      k12_type_institution = create(:institution, institution_type: :k_12_education)
      ngo_type_institution = create(:institution,
        institution_type: :non_governmental_organization_or_entity
      )
      create(:user_visit,
        visit: reserve1_visit, institution: uc_type_institution1,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve2_visit, institution: uc_type_institution1,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: k12_type_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :declined
      )
      create(:user_visit,
        visit: reserve1_visit, institution: k12_type_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :cancelled
      )
      create(:user_visit,
        visit: reserve1_visit, institution: k12_type_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :in_review
      )
      create(:user_visit,
        visit: reserve1_visit, institution: k12_type_institution,
        arrives_at: 3.year.ago, departs_at: 2.year.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: k12_type_institution,
        arrives_at: 2.year.from_now, departs_at: 3.year.from_now, status: :approved
      )
      create(:user_visit,
        visit: no_report_access_visit, institution: uc_type_institution1,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: ngo_type_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: uc_type_institution2,
        arrives_at: 2.month.ago, departs_at: 1.month.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart2Presenter.new(form: form, reserve: reserve1)

      report_part2_data = presenter.report_part2_data

      expect(report_part2_data.keys).to match_array [
        uc_type_institution1.institution_type,
        ngo_type_institution.institution_type,
      ]
      expect(report_part2_data[:university_of_california.to_s].map(&:id)).to match_array [
        uc_type_institution1.id,
        uc_type_institution2.id,
      ]
      expect(report_part2_data[:non_governmental_organization_or_entity.to_s].map(&:id)).to match_array [
        ngo_type_institution.id,
      ]
    end
  end

  describe "#fiscal_year" do
    it "is the form fiscal year" do
      annual_report = create(:annual_report, fiscal_year_ending: 2049)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart2Presenter.new(form: form)

      fiscal_year = presenter.fiscal_year

      expect(fiscal_year).to eq "2048-2049"
    end
  end

  describe "#fiscal_year_ending_options" do
    it "is an array of fiscal year options" do
      fiscal_year_options = [].tap do |arr|
        (2000..(Date.current.year + 1)).each { |year_end| arr << ["#{year_end - 1}-#{year_end}", year_end] }
      end
      presenter = Manager::Reports::ReportPart2Presenter.new

      fiscal_year_ending_options = presenter.fiscal_year_ending_options

      expect(fiscal_year_ending_options).to match_array fiscal_year_options
    end
  end

  describe "#fiscal_year_select_path" do
    it "returns the path for the fiscal year dropdown" do
      presenter = Manager::Reports::ReportPart2Presenter.new

      fiscal_year_select_path = presenter.fiscal_year_select_path

      expect(fiscal_year_select_path).to eq :report_part_2_manager_reserve_report_path
    end
  end

  describe "#annual_report_column" do
    it "returns the annual report column to update" do
      presenter = Manager::Reports::ReportPart2Presenter.new

      annual_report_column = presenter.annual_report_column

      expect(annual_report_column).to eq :part_2_approved
    end
  end

  describe "#report_part2_data_scope" do
    it "returns only institutions having associated with user_visits at the given reserve" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve3 = create(:reserve)
      reserve1_visit = create(:visit,
        reserve: reserve1, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      reserve2_visit = create(:visit,
        reserve: reserve2, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      institution1 = create(:institution)
      institution2 = create(:institution)
      institution3 = create(:institution)
      create(:user_visit,
        visit: reserve1_visit, institution: institution1,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve2_visit, institution: institution2,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: institution3,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter1 = Manager::Reports::ReportPart2Presenter.new(form: form, reserve: reserve1)
      presenter2 = Manager::Reports::ReportPart2Presenter.new(form: form, reserve: reserve3)

      report_part2_data_scope1 = presenter1.report_part2_data_scope
      report_part2_data_scope2 = presenter2.report_part2_data_scope

      expect(report_part2_data_scope1).to match_array [institution1, institution3]
      expect(report_part2_data_scope2).to match_array []
    end

    it "returns only institutions having associated with approved status user_visits" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve1_visit = create(:visit,
        reserve: reserve1, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      institution1 = create(:institution)
      create(:user_visit,
        visit: reserve1_visit, institution: create(:institution),
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :cancelled
      )
      create(:user_visit,
        visit: reserve1_visit, institution: institution1,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: create(:institution),
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :declined
      )
      create(:user_visit,
        visit: reserve1_visit, institution: create(:institution),
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :in_review
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart2Presenter.new(form: form, reserve: reserve1)

      report_part2_data_scope = presenter.report_part2_data_scope

      expect(report_part2_data_scope).to match_array [institution1]
    end

    it "returns only institutions having user_visits arrives_at and departs_at within the annual_report fiscal dates" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve1_visit = create(:visit,
        reserve: reserve1, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      institution1 = create(:institution)
      institution2 = create(:institution)
      institution3 = create(:institution)
      institution4 = create(:institution)
      institution5 = create(:institution)
      create(:user_visit,
        visit: reserve1_visit, institution: institution1,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: institution2,
        arrives_at: 3.year.ago, departs_at: 2.year.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: institution3,
        arrives_at: 2.year.from_now, departs_at: 3.year.from_now, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: institution4,
        arrives_at: 2.day.ago, departs_at: 2.year.from_now, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: institution5,
        arrives_at: 2.year.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart2Presenter.new(form: form, reserve: reserve1)

      report_part2_data_scope = presenter.report_part2_data_scope

      expect(report_part2_data_scope).to match_array [institution1, institution4, institution5]
    end

    it "returns only institutions having associated with report_access=true visits through user_visit " do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve1_visit1_access_true = create(:visit,
        reserve: reserve1, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      reserve1_visit2_access_false = create(:visit,
        reserve: reserve1, report_access: false,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      institution1 = create(:institution)
      institution2 = create(:institution)
      institution3 = create(:institution)
      institution4 = create(:institution)
      create(:user_visit,
        visit: reserve1_visit1_access_true, institution: institution1,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit2_access_false, institution: institution2,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit1_access_true, institution: institution3,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit2_access_false, institution: institution4,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart2Presenter.new(form: form, reserve: reserve1)

      report_part2_data_scope = presenter.report_part2_data_scope

      expect(report_part2_data_scope).to match_array [institution1, institution3]
    end

    it "returns institution in order of institution_types" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve1_visit = create(:visit,
        reserve: reserve1, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      uc_type_institution = create(:institution, institution_type: :university_of_california)
      k12_type_institution = create(:institution, institution_type: :k_12_education)
      business_entity_institution = create(:institution, institution_type: :business_entity)
      ngo_type_institution = create(:institution,
        institution_type: :non_governmental_organization_or_entity
      )
      california_community_college_institution = create(:institution,
        institution_type: :california_community_college)
      create(:user_visit,
        visit: reserve1_visit, institution: k12_type_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: ngo_type_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: uc_type_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: california_community_college_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: business_entity_institution,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart2Presenter.new(form: form, reserve: reserve1)

      report_part2_data_scope = presenter.report_part2_data_scope

      expect(report_part2_data_scope).to match_array [
        uc_type_institution,
        california_community_college_institution,
        k12_type_institution,
        ngo_type_institution,
        business_entity_institution,
      ]
    end

    it "returns institution in order of institution name" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve1_visit = create(:visit,
        reserve: reserve1, report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
        start_date: 4.year.ago.to_date, end_date: 4.year.from_now.to_date
      )
      institution_a = create(:institution, name: "institution a")
      institution_b = create(:institution, name: "institution b")
      institution_c = create(:institution, name: "institution c")
      create(:user_visit,
        visit: reserve1_visit, institution: institution_c,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: institution_a,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: reserve1_visit, institution: institution_b,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart2Presenter.new(form: form, reserve: reserve1)

      report_part2_data_scope = presenter.report_part2_data_scope

      expect(report_part2_data_scope).to match_array [
        institution_a,
        institution_b,
        institution_c,
      ]
    end
  end
end
