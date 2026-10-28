require "rails_helper"

RSpec.describe Manager::Projects::ActivityAndNotesController, type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:project) { create(:project, reserve: reserve) }

  before { create(:reserve_personnel, user: user, reserve: reserve) }

  describe "GET /manager/reserves/:reserve_id/projects/:project_id/activity_and_notes" do
    it "renders the activity log and the reserve notes" do
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}/activity_and_notes"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("section.activity-and-notes")
      expect(doc).to have_css("#activity_logs")
      expect(doc).to have_css("#reserve_notes")
      expect(doc).to have_css("#note-input")
    end
  end
end
