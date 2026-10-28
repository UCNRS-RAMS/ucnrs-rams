require "rails_helper"

RSpec.describe Manager::Projects::VisitsController, type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve, name: "Test Reserve") }
  let(:project) { create(:project, reserve: reserve) }

  before { create(:reserve_personnel, user: user, reserve: reserve) }

  describe "GET /manager/reserves/:reserve_id/projects/:project_id/visits" do
    it "renders a row per project visit" do
      create_list(:visit, 3, project: project)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}/visits"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("section.project-visits-index")
      expect(doc).to have_css("#project-visit-requests tr.visit", count: 3)
    end

    it "renders the visit values in the table row" do
      create(:visit, project: project, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}/visits"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      row = doc.find("#project-visit-requests tr.visit")
      expect(row).to have_css("td.date-range")
      expect(row).to have_css("td:nth-child(3)", text: "Test Reserve")
    end
  end
end
