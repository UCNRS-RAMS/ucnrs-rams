require "rails_helper"

RSpec.describe ProjectsController, type: :request do
  describe "GET /projects" do
    def project_ids_on_page
      doc = Capybara.string(response.body)
      doc.all("tr.project").map { |row| row[:id] }
    end

    it "lists the user's projects ordered by visit date with their visit details" do
      travel_to Time.zone.local(2021, 10, 1, 9, 0) do
        user = create(:user, :confirmed)
        reserve1 = create(:reserve, short_name: "Bodega Bay")
        reserve2 = create(:reserve, short_name: "Alpine Heights")
        project1 = create(:project, title: "Project 1", status: "Open", project_type: "Research")
        project2 = create(:project, title: "Project 2", status: "Open", project_type: "Research")
        project3 = create(:project, title: "Project 3", status: "Incomplete", project_type: "Class")
        project4 = create(:project, title: "Project 4", status: "Closed", project_type: "Class")
        Project.find_each do |project|
          create(:project_team_membership, project: project, user: user, active: true)
        end
        create(
          :visit,
          reserve: reserve2,
          project: project1,
          starts_at: Time.zone.local(2021, 12, 31),
          ends_at: Time.zone.local(2022, 12, 31),
          submitted_at: Time.current,
        )
        create(
          :visit,
          reserve: reserve1,
          project: project2,
          starts_at: Time.zone.local(2021, 10, 11),
          ends_at: Time.zone.local(2021, 11, 11),
          submitted_at: Time.current,
        )
        create(
          :visit,
          reserve: reserve1,
          project: project4,
          starts_at: Time.zone.local(2020, 1, 1),
          ends_at: Time.zone.local(2021, 1, 1),
          submitted_at: Time.current,
        )
        other_users_project = create(:project, title: "Someone Else's Project")
        create(
          :project_team_membership,
          project: other_users_project,
          user: create(:user, :confirmed),
          active: true,
        )
        sign_in(user)

        get "/projects"

        expect(response).to be_ok
        expect(Capybara.string(response.body)).to have_css("body.projects-index")
        expect(project_ids_on_page).to eq [
          "project_#{project3.id}",
          "project_#{project2.id}",
          "project_#{project1.id}",
          "project_#{project4.id}"
        ]
        expect(Capybara.string(response.body)).to have_link(
          "Project 1",
          href: "/projects/#{project1.id}",
        )
        row = Capybara.string(response.body).find("tr#project_#{project1.id}")
        expect(row).to have_text("1 visit")
        expect(row).to have_text("Alpine Heights")
        expect(Capybara.string(response.body).find("tr#project_#{project3.id}")).to have_text("0 visits")

        get "/projects", params: { status: Project::ACTIVE_FILTER }

        expect(project_ids_on_page).to eq [ "project_#{project2.id}", "project_#{project1.id}" ]

        get "/projects", params: { status: Project::INCOMPLETE_FILTER }

        expect(project_ids_on_page).to eq [ "project_#{project3.id}" ]

        get "/projects", params: { status: Project::INACTIVE_FILTER }

        expect(project_ids_on_page).to eq [ "project_#{project4.id}" ]

        get "/projects", params: { status: Project::ALL_FILTER }

        expect(project_ids_on_page.length).to eq 4
      end
    end

    it "paginates the projects ten at a time" do
      user = create(:user, :confirmed)
      25.times do |n|
        project = create(:project, title: "Project #{n}", owner: user)
        create(:project_team_membership, project: project, user: user, active: true)
      end
      sign_in(user)

      get "/projects"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("tr.project", count: 10)
      expect(doc).to have_css("nav.pagination")
      expect(doc).to have_css("span.page.current", text: "1")

      get "/projects", params: { page: 3 }

      doc = Capybara.string(response.body)
      expect(doc).to have_css("tr.project", count: 5)
      expect(doc).to have_css("span.page.current", text: "3")

      get "/projects", params: { status: Project::INCOMPLETE_FILTER }

      doc = Capybara.string(response.body)
      expect(doc).to have_css("tr.project", count: 0)
      expect(doc).to have_no_css("nav.pagination")
    end
  end
end
