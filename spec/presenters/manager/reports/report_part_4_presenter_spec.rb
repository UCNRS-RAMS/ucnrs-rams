require "rails_helper"

RSpec.describe Manager::Reports::ReportPart4Presenter do
  describe "#report_part4_data" do
    it "returns only projects wrapped in ProjectPresenter" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      visit1 = create(:visit,
        reserve: reserve1, report_access: true,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      project1 = create(:project, visits: [visit1])
      create(:user_visit,
        visit: visit1,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:reserve_id).and_return(reserve1.id)
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart4Presenter.new(form: form)

      report_part4_data = presenter.report_part4_data

      expect(report_part4_data).to all(be_a(ProjectPresenter))
    end
  end

  describe "#fiscal_year_select_path" do
    it "returns the path for the fiscal year dropdown" do
      presenter = Manager::Reports::ReportPart4Presenter.new

      fiscal_year_select_path = presenter.fiscal_year_select_path

      expect(fiscal_year_select_path).to eq :report_part_4_manager_reserve_report_path
    end
  end

  describe "#annual_report_column" do
    it "returns the annual report column to update" do
      presenter = Manager::Reports::ReportPart4Presenter.new

      annual_report_column = presenter.annual_report_column

      expect(annual_report_column).to eq :part_4_approved
    end
  end

  describe "#report_part4_data_scope" do
    it "returns only projects having having associated with visit at the given reserve" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve1_visit = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date)
      reserve2_visit = create(:visit,
        reserve: reserve2, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date)
      project1 = create(:project, visits: [reserve1_visit])
      project2 = create(:project, visits: [reserve2_visit])
      create(:user_visit,
        visit: reserve1_visit,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved)
      annual_report = double AnnualReport
      allow(annual_report).to receive(:reserve_id).and_return(reserve1.id)
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart4Presenter.new(form: form)

      report_part4_data_scope = presenter.report_part4_data_scope

      expect(report_part4_data_scope).to match_array [project1]
    end

    it "returns only research projects" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      project1 = create(:project, project_type: :research)
      project2 = create(:project, project_type: :class)
      project3 = create(:project, project_type: :research)
      reserve1_visit1 = create(:visit, project: project1,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date)
      reserve1_visit2 = create(:visit, project: project2,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date)
      reserve1_visit3 = create(:visit, project: project3,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date)
      create(:user_visit,
        visit: reserve1_visit1,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved)
      create(:user_visit,
        visit: reserve1_visit2,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved)
      create(:user_visit,
        visit: reserve1_visit3,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved)
      annual_report = double AnnualReport
      allow(annual_report).to receive(:reserve_id).and_return(reserve1.id)
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart4Presenter.new(form: form)

      report_part4_data_scope = presenter.report_part4_data_scope

      expect(report_part4_data_scope).to match_array [project1, project3]
    end

    it "returns only projects having having associated with visit with enabled report_access" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      visit1 = create(:visit,
        reserve: reserve1, report_access: false, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      visit2 = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      project1 = create(:project, visits: [visit1])
      project2 = create(:project, visits: [visit2])
      create(:user_visit,
        visit: visit1,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: visit2,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:reserve_id).and_return(reserve1.id)
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart4Presenter.new(form: form)

      report_part4_data_scope = presenter.report_part4_data_scope

      expect(report_part4_data_scope).to match_array [project2]
    end

    it "returns only projects having having associated with approved status user_visits" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      visit1 = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      visit2 = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      project1 = create(:project, visits: [visit1])
      project2 = create(:project, visits: [visit2])
      create(:user_visit,
        visit: visit1,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :in_review
      )
      create(:user_visit,
        visit: visit2,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:reserve_id).and_return(reserve1.id)
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart4Presenter.new(form: form)

      report_part4_data_scope = presenter.report_part4_data_scope

      expect(report_part4_data_scope).to match_array [project2]
    end

    it "returns only projects having having associated with user_visits arrives_at and departs_at within the annual_report fiscal dates" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      visit1 = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      visit2 = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      visit3 = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      visit4 = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      visit5 = create(:visit,
        reserve: reserve1, report_access: true, status: :approved,
        starts_at: 4.years.ago, ends_at: 4.years.from_now,
        start_date: 4.years.ago.to_date, end_date: 4.years.from_now.to_date
      )
      project1 = create(:project, visits: [visit1])
      project2 = create(:project, visits: [visit2])
      project3 = create(:project, visits: [visit3])
      project4 = create(:project, visits: [visit4])
      project5 = create(:project, visits: [visit5])
      create(:user_visit,
        visit: visit1,
        arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved
      )
      create(:user_visit,
        visit: visit2,
        arrives_at: 3.years.ago, departs_at: 2.year.ago, status: :approved
      )
      create(:user_visit,
        visit: visit3,
        arrives_at: 2.year.from_now, departs_at: 3.years.from_now, status: :approved
      )
      create(:user_visit,
        visit: visit4,
        arrives_at: 2.days.ago, departs_at: 2.year.from_now, status: :approved
      )
      create(:user_visit,
        visit: visit5,
        arrives_at: 2.year.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:reserve_id).and_return(reserve1.id)
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart4Presenter.new(form: form)

      report_part4_data_scope = presenter.report_part4_data_scope

      expect(report_part4_data_scope).to match_array [project1, project4, project5]
    end
  end
end
