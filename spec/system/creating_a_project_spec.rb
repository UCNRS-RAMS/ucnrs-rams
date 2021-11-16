require "rails_helper"

RSpec.describe "Creating a project", type: :system, js: true do
  describe "when viewing the new project form" do
    it "displays a dismissable modal on page load", js: true do
      user = create(:user, :confirmed)
      sign_in(user)
      flow = CreateProjectFlow.new(page)

      flow.visit_projects_page
      flow.click_create_new_project
      expect(flow).to have_modal_displayed
      expect(page).to be_axe_clean

      flow.dismiss_modal

      expect(flow).not_to have_modal_displayed
      expect(page).to be_axe_clean
    end
  end
end
