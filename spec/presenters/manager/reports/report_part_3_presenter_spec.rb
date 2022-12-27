require "rails_helper"

RSpec.describe Manager::Reports::ReportPart3Presenter do
  describe "delegations" do
    subject { Manager::Reports::ReportPart3Presenter.new(form: :form) }
    it { is_expected.to delegate_method(:annual_report).to(:form).with_prefix(true) }
    it { is_expected.to delegate_method(:fiscal_year_ending).to(:form_annual_report) }
    it { is_expected.to delegate_method(:reserve_id).to(:form_annual_report) }
  end

  describe "#report_part3_data" do
    it "creates a ProjectPresenter for each project" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve = create(:reserve)
      project = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved),
            ]
          ),
        ]
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report).to receive(:reserve_id).and_return(reserve.id)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart3Presenter.new(form: form)

      report_part3_data = presenter.report_part3_data
      expect(report_part3_data.values.map(&:values).flatten).to all(be_a(ProjectPresenter))
    end
  end

  describe "#fiscal_year" do
    it "is the form fiscal year" do
      annual_report = create(:annual_report, fiscal_year_ending: 2049)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart3Presenter.new(form: form)

      fiscal_year = presenter.fiscal_year

      expect(fiscal_year).to eq "2048-2049"
    end
  end

  describe "#fiscal_year_ending_options" do
    it "is an array of fiscal year options" do
      fiscal_year_options = (2000..(Date.current.year + 1))
        .map { |year_end| ["#{year_end - 1}-#{year_end}", year_end] }
      presenter = Manager::Reports::ReportPart3Presenter.new

      fiscal_year_ending_options = presenter.fiscal_year_ending_options

      expect(fiscal_year_ending_options).to match_array fiscal_year_options
    end
  end

  describe "#fiscal_year_select_path" do
    it "returns the path for the fiscal year dropdown" do
      presenter = Manager::Reports::ReportPart3Presenter.new

      fiscal_year_select_path = presenter.fiscal_year_select_path

      expect(fiscal_year_select_path).to eq :report_part_3_manager_reserve_report_path
    end
  end

  describe "#annual_report_column" do
    it "returns the annual report column to update" do
      presenter = Manager::Reports::ReportPart3Presenter.new

      annual_report_column = presenter.annual_report_column

      expect(annual_report_column).to eq :part_3_approved
    end
  end

  describe "#report_part3_data_scope" do
    it "returns only projects having associated with user_visits at the given reserve" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve3 = create(:reserve)
      project1 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve1, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved),
            ]
          ),
        ]
      )
      project2 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve2, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved),
            ]
          ),
        ]
      )
      project3 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve1, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved),
            ]
          ),
        ]
      )
      annual_report1 = double AnnualReport
      allow(annual_report1).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report1).to receive(:reserve_id).and_return(reserve1.id)
      form1 = AnnualReportForm.new(annual_report: annual_report1)
      presenter1 = Manager::Reports::ReportPart3Presenter.new(form: form1)
      annual_report2 = double AnnualReport
      allow(annual_report2).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report2).to receive(:reserve_id).and_return(reserve3.id)
      form2 = AnnualReportForm.new(annual_report: annual_report2)
      presenter2 = Manager::Reports::ReportPart3Presenter.new(form: form2)

      report_part3_data_scope1 = presenter1.report_part3_data_scope
      report_part3_data_scope2 = presenter2.report_part3_data_scope

      expect(report_part3_data_scope1).to match_array [project1, project3]
      expect(report_part3_data_scope2).to match_array []
    end

    it "returns only projects having associated with approved status user_visits" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve = create(:reserve)
      project1 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :cancelled),
            ]
          ),
        ]
      )
      project2 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved),
            ]
          ),
        ]
      )
      project3 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :declined),
            ]
          ),
        ]
      )
      project4 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :in_review),
            ]
          ),
        ]
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report).to receive(:reserve_id).and_return(reserve.id)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart3Presenter.new(form: form)

      report_part3_data_scope = presenter.report_part3_data_scope

      expect(report_part3_data_scope).to match_array [project2]
    end

    it "returns only projects having user_visits arrives_at and departs_at within the annual_report fiscal dates" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve = create(:reserve)
      project1 = create(:project, project_type: :class)
      project1_visit = create(:visit, project: project1, reserve: reserve,
        report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
      )
      create(:user_visit, visit: project1_visit,
        arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved
      )
      project2 = create(:project, project_type: :class)
      project2_visit = create(:visit, project: project2, reserve: reserve,
        report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
      )
      create(:user_visit, visit: project2_visit,
        arrives_at: 3.year.ago, departs_at: 2.year.ago, status: :approved
      )
      project3 = create(:project, project_type: :class)
      project3_visit = create(:visit, project: project3, reserve: reserve,
        report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
      )
      create(:user_visit, visit: project3_visit,
        arrives_at: 2.year.from_now, departs_at: 3.year.from_now, status: :approved
      )
      project4 = create(:project, project_type: :class)
      project4_visit = create(:visit, project: project4, reserve: reserve,
        report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
      )
      create(:user_visit, visit: project4_visit,
        arrives_at: 2.day.ago, departs_at: 2.year.from_now, status: :approved
      )
      project5 = create(:project, project_type: :class)
      project5_visit = create(:visit, project: project5, reserve: reserve,
        report_access: true,
        starts_at: 4.year.ago, ends_at: 4.year.from_now,
      )
      create(:user_visit, visit: project5_visit,
        arrives_at: 2.year.ago, departs_at: 1.day.ago, status: :approved
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report).to receive(:reserve_id).and_return(reserve.id)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart3Presenter.new(form: form)

      report_part3_data_scope = presenter.report_part3_data_scope

      expect(report_part3_data_scope).to match_array [project1, project4, project5]
    end

    it "returns only institutions having associated with report_access=true visits through user_visit " do
      travel_to Time.zone.local(2022, 2, 22)
      reserve = create(:reserve)
      project1 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve, report_access: false,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved),
            ]
          ),
        ]
      )
      project2 = create(:project, project_type: :class,
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved),
            ]
          ),
          create(:visit,
            reserve: reserve, report_access: false,
            starts_at: 4.year.ago, ends_at: 4.year.from_now,
            user_visits: [
              create(:user_visit, arrives_at: 2.day.ago, departs_at: 1.day.ago, status: :approved),
            ]
          ),
        ]
      )
      project3 = create(:project)
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report).to receive(:reserve_id).and_return(reserve.id)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart3Presenter.new(form: form)

      report_part3_data_scope = presenter.report_part3_data_scope

      expect(report_part3_data_scope).to match_array [project2]
    end
  end
end
