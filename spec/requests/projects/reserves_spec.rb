require "rails_helper"

RSpec.describe Projects::ReservesController, type: :request do
  describe "GET /projects/:project_id/reserves" do
    it "pre-selects the saved reserves when the form is shown again" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project, status: :open)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )
      interested_reserve = create(:reserve)
      other_reserve = create(:reserve)
      create(:project_reserve_interest, project: project, reserve: interested_reserve)

      get "/projects/#{project.id}/reserves"

      doc = Capybara.string(response.body)
      expect(doc).to have_checked_field("reserve-#{interested_reserve.id}")
      expect(doc).to have_unchecked_field("reserve-#{other_reserve.id}")
    end
  end
end
