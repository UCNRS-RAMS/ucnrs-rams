require "rails_helper"

RSpec.describe "Projects Index" do
  describe "viewing and filtering projects" do
    it "can filter projects by status", js: true do
      user = create(:user, :confirmed)
      reserve1 = create(:reserve, short_name: "Bodega Bay")
      reserve2 = create(:reserve, short_name: "Alpine Heights")
      project1 = create(:project, title: "Project 1", status: "Open", project_type: "Research", start_date: Date.new(2021, 12, 31), end_date: Date.new(2023, 12, 31))
      project2 = create(:project, title: "Project 2", status: "Open", project_type: "Research", start_date: Date.new(2021, 8, 1), end_date: Date.new(2021, 12, 1))
      project3 = create(:project, title: "Project 3", status: "Incomplete", project_type: "Class", start_date: nil, end_date: nil)
      project4 = create(:project, title: "Project 4", status: "Closed", project_type: "Class", start_date: Date.new(2019, 12, 31), end_date: Date.new(2021, 1, 2))
      Project.find_each { |project| create(:project_team_membership, project: project, user: user, active: true) }
      travel_to Date.new(2021, 10, 1) do
        create(:visit, reserve: reserve2, project: project1, start_date: Date.new(2021, 12, 31), end_date: Date.new(2022, 12, 31))
        create(:visit, reserve: reserve1, project: project2, start_date: Date.new(2021, 10, 11), end_date: Date.new(2021, 11, 11))
        create(:visit, reserve: reserve1, project: project4, start_date: Date.new(2020, 1, 1), end_date: Date.new(2021, 1, 1))

        flow = ProjectIndexFlow.new(page)
        sign_in(user)
  
        flow.visit_projects_index_page
        expect(flow).to be_on_projects_index_page
        expect(flow).to have_active_my_projects_tab
        expect(flow).to have_projects_count(4)
        expect(flow).to have_projects_in_order([project3, project2, project1, project4])
        expect(flow).to have_project_with(
          id: project3.id,
          title: "Project 3",
          timeframe: "N/A",
          project_type: "Class",
          number_of_visits: 0,
          most_recent_visit: "N/A",
          reserve_name: "N/A",
        )
        expect(flow).to have_project_with(
          id: project2.id,
          title: "Project 2",
          timeframe: "Aug 1 - Dec 1, 2021",
          project_type: "Research",
          number_of_visits: 1,
          most_recent_visit: "Oct 11, 2021",
          reserve_name: "Bodega Bay",
        )
        expect(flow).to have_project_with(
          id: project1.id,
          title: "Project 1",
          timeframe: "Dec 31, 2021 - Dec 31, 2023",
          project_type: "Research",
          number_of_visits: 1,
          most_recent_visit: "Dec 31, 2021",
          reserve_name: "Alpine Heights",
        )
        expect(flow).to have_project_with(
          id: project4.id,
          title: "Project 4",
          timeframe: "Dec 31, 2019 - Jan 2, 2021",
          project_type: "Class",
          number_of_visits: 1,
          most_recent_visit: "Jan 01, 2020",
          reserve_name: "Bodega Bay",
        )
        expect(page).to be_axe_clean

        flow.filter_by_status("Active Projects")
        expect(flow).to have_projects_count(2)
        expect(flow).to have_projects_in_order([project2, project1])
        expect(flow).to have_project_with(
          id: project2.id,
          title: "Project 2",
          timeframe: "Aug 1 - Dec 1, 2021",
          project_type: "Research",
          number_of_visits: 1,
          most_recent_visit: "Oct 11, 2021",
          reserve_name: "Bodega Bay",
        )
        expect(flow).to have_project_with(
          id: project1.id,
          title: "Project 1",
          timeframe: "Dec 31, 2021 - Dec 31, 2023",
          project_type: "Research",
          number_of_visits: 1,
          most_recent_visit: "Dec 31, 2021",
          reserve_name: "Alpine Heights",
        )
        expect(page).to be_axe_clean
  
        flow.filter_by_status("Incomplete Projects")
        expect(flow).to have_projects_count(1)
        expect(flow).to have_projects_in_order([project3])
        expect(flow).to have_project_with(
          id: project3.id,
          title: "Project 3",
          timeframe: "N/A",
          project_type: "Class",
          number_of_visits: 0,
          most_recent_visit: "N/A",
          reserve_name: "N/A",
        )
        expect(page).to be_axe_clean
  
        flow.filter_by_status("Inactive Projects")
        expect(flow).to have_projects_count(1)
        expect(flow).to have_projects_in_order([project4])
        expect(flow).to have_project_with(
          id: project4.id,
          title: "Project 4",
          timeframe: "Dec 31, 2019 - Jan 2, 2021",
          project_type: "Class",
          number_of_visits: 1,
          most_recent_visit: "Jan 01, 2020",
          reserve_name: "Bodega Bay",
        )
        expect(page).to be_axe_clean
  
        flow.filter_by_status("All Projects")
        expect(flow).to have_projects_count(4)
        expect(flow).to have_project_with(
          id: project3.id,
          title: "Project 3",
          timeframe: "N/A",
          project_type: "Class",
          number_of_visits: 0,
          most_recent_visit: "N/A",
          reserve_name: "N/A",
        )
        expect(flow).to have_project_with(
          id: project2.id,
          title: "Project 2",
          timeframe: "Aug 1 - Dec 1, 2021",
          project_type: "Research",
          number_of_visits: 1,
          most_recent_visit: "Oct 11, 2021",
          reserve_name: "Bodega Bay",
        )
        expect(flow).to have_project_with(
          id: project1.id,
          title: "Project 1",
          timeframe: "Dec 31, 2021 - Dec 31, 2023",
          project_type: "Research",
          number_of_visits: 1,
          most_recent_visit: "Dec 31, 2021",
          reserve_name: "Alpine Heights",
        )
        expect(flow).to have_project_with(
          id: project4.id,
          title: "Project 4",
          timeframe: "Dec 31, 2019 - Jan 2, 2021",
          project_type: "Class",
          number_of_visits: 1,
          most_recent_visit: "Jan 01, 2020",
          reserve_name: "Bodega Bay",
        )
      end
      travel_back
    end
  end

  describe "paginated projects" do
    it "paginates projects displaying 10 at a time", js: true do
      user = create(:user, :confirmed)
      25.times do |n|
        project = create(:project, title: "Project #{n}", owner: user)
        create(:project_team_membership, project: project, user: user, active: true)
      end

      flow = ProjectIndexFlow.new(page)
      sign_in(user)

      flow.visit_projects_index_page
      expect(flow).to be_on_projects_index_page
      expect(flow).to have_active_my_projects_tab
      expect(flow).to have_displayed_projects(10)
      expect(flow).to have_pagination_link("next")
      expect(flow).to have_pagination_link("last")
      expect(flow).to have_selected_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_page_number_link(3)
      expect(page).to be_axe_clean.skipping(:"color-contrast")

      flow.go_to_page(3)
      expect(flow).to have_displayed_projects(5)
      expect(flow).to have_pagination_link("first")
      expect(flow).to have_pagination_link("prev")
      expect(flow).to have_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_selected_page_number_link(3)

      flow.filter_by_status("Incomplete Projects")
      expect(flow).to have_displayed_projects(0)
      expect(flow).to have_no_pagination_links
    end
  end
end
