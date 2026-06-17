require "rails_helper"

RSpec.describe Manager::Projects::ReservesController, type: :request do
  describe "GET /manager/reserves/:reserve_id/projects/:project_id/reserves" do
    it "renders the reserve selection step for a reserve manager" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, status: :incomplete, reserve: reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      selectable_reserve = create(:reserve)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}/reserves"

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css("ul.reserve-checkboxes")
      expect(page).to have_css("#reserve-#{selectable_reserve.id}")
    end
  end
end
