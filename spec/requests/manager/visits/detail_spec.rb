require "rails_helper"

RSpec.describe Manager::Visits::DetailController, type: :request do
  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/detail/edit" do
    it "renders the visit-details frame for a super admin who manages no reserve" do
      visit = create(:visit)
      sign_in(create(:user, :confirmed, admin: true))

      get "/manager/reserves/#{visit.reserve_id}/visits/#{visit.id}/detail/edit",
        headers: { "Turbo-Frame" => "visit-details" }

      expect(response).to be_ok
      expect(Capybara.string(response.body)).to have_css("turbo-frame#visit-details")
    end

    it "renders the visit-details frame for a manager of the reserve" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/visits/#{visit.id}/detail/edit",
        headers: { "Turbo-Frame" => "visit-details" }

      expect(response).to be_ok
      expect(Capybara.string(response.body)).to have_css("turbo-frame#visit-details")
    end
  end
end
