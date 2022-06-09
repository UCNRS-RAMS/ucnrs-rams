require "rails_helper"

RSpec.describe "Manager Project Show" do
  describe "it displays project show page" do
    it "includes summary box and menu bar", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project)

      sign_in(user)
      flow = ProjectShowFlow.new(page: page, project_id: project.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(page).to have_css(".project-summary-box")
      expect(page).to have_css(".project-menu-bar")
    end
  end
end
