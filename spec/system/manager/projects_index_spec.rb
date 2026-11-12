require "rails_helper"

RSpec.describe "Manager Projects Index" do
  describe "paginated projects" do
    it "paginates projects displaying 10 at a time", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      25.times do |n|
        project = create(:project, title: "Project #{n}")
        create(:visit, project: project, reserve: reserve, start_date: Time.zone.today, end_date: Date.tomorrow)
      end

      flow = Manager::ProjectIndexFlow.new(page)
      sign_in(user)

      flow.visit_manager_projects_index_page(reserve)
      expect(flow).to be_on_manager_projects_index_page
      expect(flow).to have_active_projects_tab
      expect(flow).to have_displayed_projects(10)
      expect(flow).to have_pagination_link("next")
      expect(flow).to have_pagination_link("last")
      expect(flow).to have_selected_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_page_number_link(3)
      expect(page).to be_axe_clean

      flow.go_to_last_page
      expect(flow).to have_displayed_projects(5)
      expect(flow).to have_pagination_link("first")
      expect(flow).to have_pagination_link("prev")
      expect(flow).to have_page_number_link(1)
      expect(flow).to have_page_number_link(2)
      expect(flow).to have_selected_page_number_link(3)
    end
  end

  describe "proposed projects" do
    it "lists projects that asked to be contacted in a labelled table" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      requested = create(:project, title: "Wants a call", status: :open)
      create(:visit, project: requested, reserve: reserve)
      create(:project, title: "Quiet project", status: :open)
      create(:project_reserve_interest, project: requested, reserve: reserve)
      sign_in(user)

      visit "/manager/reserves/#{reserve.id}/projects"

      within(".contact-requested-subsection") do
        expect(page).to have_content("Proposed Projects")
        expect(page).to have_css("tr.project", count: 1)
        expect(page).to have_link("Wants a call")
      end
    end

    it "hides the table when no project asked to be contacted" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      visit "/manager/reserves/#{reserve.id}/projects"

      expect(page).to have_no_css(".contact-requested-subsection")
    end
  end
end
