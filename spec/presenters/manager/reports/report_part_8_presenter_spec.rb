require "rails_helper"

RSpec.describe Manager::Reports::ReportPart8Presenter do
  describe "#fiscal_year_select_path" do
    it "returns the path for the fiscal year dropdown" do
      presenter = Manager::Reports::ReportPart8Presenter.new

      fiscal_year_select_path = presenter.fiscal_year_select_path

      expect(fiscal_year_select_path).to eq :report_part_8_manager_reserve_report_path
    end
  end

  describe "#report_part8_data_scope" do
    it "returns only projects having associated with user_visits at the given reserve" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      reserve3 = create(:reserve)
      project1_owner = create(:user)
      project2_owner = create(:user)
      project3_owner = create(:user)
      project1 = create(:project, project_type: :public_use, owner: project1_owner,
        members: [project1_owner],
        visits: [
          create(:visit,
            reserve: reserve1, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago,
                status: :approved),
            ]),
        ]
      )
      project2 = create(:project, project_type: :public_use, owner: project2_owner,
        members: [project2_owner],
        visits: [
          create(:visit,
            reserve: reserve2, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago,
                status: :approved),
            ]),
        ]
      )
      project3 = create(:project, project_type: :public_use, owner: project3_owner,
        members: [project3_owner],
        visits: [
          create(:visit,
            reserve: reserve1, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago,
                status: :approved),
            ]),
        ]
      )
      annual_report1 = double AnnualReport
      allow(annual_report1).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report1).to receive(:reserve_id).and_return(reserve1.id)
      form1 = AnnualReportForm.new(annual_report: annual_report1)
      presenter1 = Manager::Reports::ReportPart8Presenter.new(form: form1)
      annual_report2 = double AnnualReport
      allow(annual_report2).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report2).to receive(:reserve_id).and_return(reserve3.id)
      form2 = AnnualReportForm.new(annual_report: annual_report2)
      presenter2 = Manager::Reports::ReportPart8Presenter.new(form: form2)

      report_part8_data_scope1 = presenter1.report_part8_data_scope
      report_part8_data_scope2 = presenter2.report_part8_data_scope

      expect(report_part8_data_scope1).to match_array [project1, project3]
      expect(report_part8_data_scope2).to match_array []
    end

    it "returns only projects with project_type public_use" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve = create(:reserve)
      project1_owner = create(:user)
      project2_owner = create(:user)
      project3_owner = create(:user)
      project1 = create(:project, project_type: :public_use, owner: project1_owner,
        members: [project1_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved),
            ]),
        ]
      )
      project2 = create(:project, project_type: :research, owner: project2_owner,
        members: [project2_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved),
            ]),
        ]
      )
      project3 = create(:project, project_type: :public_use, owner: project3_owner,
        members: [project3_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved),
            ]),
        ]
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report).to receive(:reserve_id).and_return(reserve.id)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart8Presenter.new(form: form)

      report_part8_data_scope = presenter.report_part8_data_scope

      expect(report_part8_data_scope).to match_array [project1, project3]
    end

    it "returns only projects having associated with approved status user_visits" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve = create(:reserve)
      project1_owner = create(:user)
      project2_owner = create(:user)
      project3_owner = create(:user)
      project4_owner = create(:user)
      project1 = create(:project, project_type: :public_use, owner: project1_owner,
        members: [project1_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :cancelled),
            ]),
        ]
      )
      project2 = create(:project, project_type: :public_use, owner: project2_owner,
        members: [project2_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved),
            ]),
        ]
      )
      project3 = create(:project, project_type: :public_use, owner: project3_owner,
        members: [project3_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :denied),
            ]),
        ]
      )
      project4 = create(:project, project_type: :public_use, owner: project4_owner,
        members: [project4_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :in_review),
            ]),
        ]
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report).to receive(:reserve_id).and_return(reserve.id)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart8Presenter.new(form: form)

      report_part8_data_scope = presenter.report_part8_data_scope

      expect(report_part8_data_scope).to match_array [project2]
    end

    it "returns only projects having user_visits arrives_at and departs_at within the annual_report fiscal dates" do
      travel_to Time.zone.local(2022, 2, 22)
      reserve = create(:reserve)
      project1_owner = create(:user)
      project2_owner = create(:user)
      project3_owner = create(:user)
      project4_owner = create(:user)
      project5_owner = create(:user)
      project1 = create(:project, project_type: :public_use,
        owner: project1_owner, members: [project1_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved),
            ]),
        ]
      )
      project2 = create(:project, project_type: :public_use,
        owner: project2_owner, members: [project2_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 3.years.ago, departs_at: 2.years.ago, status: :approved),
            ]),
        ]
      )
      project3 = create(:project, project_type: :public_use,
        owner: project3_owner, members: [project3_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.years.from_now, departs_at: 3.years.from_now, status: :approved),
            ]),
        ]
      )
      project4 = create(:project, project_type: :public_use,
        owner: project4_owner, members: [project4_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 2.years.from_now, status: :approved),
            ]),
        ]
      )
      project5 = create(:project, project_type: :public_use,
        owner: project5_owner, members: [project5_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.years.ago, departs_at: 1.day.ago, status: :approved),
            ]),
        ]
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report).to receive(:reserve_id).and_return(reserve.id)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart8Presenter.new(form: form)

      report_part8_data_scope = presenter.report_part8_data_scope

      expect(report_part8_data_scope).to match_array [project1, project4, project5]
    end

    it "returns only institutions having associated with report_access=true visits through user_visit " do
      travel_to Time.zone.local(2022, 2, 22)
      reserve = create(:reserve)
      project1_owner = create(:user)
      project2_owner = create(:user)
      project1 = create(:project, project_type: :public_use, owner: project1_owner,
        members: [project1_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: false,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved),
            ]),
        ]
      )
      project2 = create(:project, project_type: :public_use, owner: project2_owner,
        members: [project2_owner],
        visits: [
          create(:visit,
            reserve: reserve, report_access: true,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved),
            ]),
          create(:visit,
            reserve: reserve, report_access: false,
            user_visits: [
              create(:user_visit, arrives_at: 2.days.ago, departs_at: 1.day.ago, status: :approved),
            ]),
        ]
      )
      annual_report = double AnnualReport
      allow(annual_report).to receive(:fiscal_year_ending).and_return(Date.current.year)
      allow(annual_report).to receive(:reserve_id).and_return(reserve.id)
      form = AnnualReportForm.new(annual_report: annual_report)
      presenter = Manager::Reports::ReportPart8Presenter.new(form: form)

      report_part8_data_scope = presenter.report_part8_data_scope

      expect(report_part8_data_scope).to match_array [project2]
    end
  end
end
