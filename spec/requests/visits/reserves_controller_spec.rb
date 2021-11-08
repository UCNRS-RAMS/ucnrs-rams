require "rails_helper"

RSpec.describe Visits::ReservesController, type: :request do
  describe "/visits/reserves" do
    it "returns reserves as a select dropdown" do
      user = create(:user, :confirmed)
      project = create(:project, project_type: "Research")
      reserve = create(:reserve, pulldown_name: "A neat reserve", research_projects_accepted: true)
      sign_in(user)

      get "/visits/reserves?project_type=research"

      page = Capybara.string(response.body)
      expect(page).to have_select(
        "visit_reserve_id",
        selected: nil,
        with_options: ["A neat reserve"]
      )
    end

    it "returns reserve select with the 'reserve_id' selected" do
      user = create(:user, :confirmed)
      project = create(:project, project_type: "Research")
      reserve = create(:reserve, pulldown_name: "A neat reserve", research_projects_accepted: true)
      sign_in(user)

      get "/visits/reserves?project_type=research&reserve_id=#{reserve.id}"

      page = Capybara.string(response.body)
      expect(page).to have_select("visit_reserve_id", selected: "A neat reserve")
    end
  end
end
