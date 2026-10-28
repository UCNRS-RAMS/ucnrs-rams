require "rails_helper"

RSpec.describe Manager::Projects::FundingsController, type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:project) { create(:project, reserve: reserve) }

  before { create(:reserve_personnel, user: user, reserve: reserve) }

  describe "GET /manager/reserves/:reserve_id/projects/:project_id/fundings" do
    it "renders the new funding form and the project fundings table" do
      create(:funding, project: project, title: "Newt Migration Grant")
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}/fundings"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css(".add-funding-form")
      expect(doc).to have_css("#project-fundings-index")
      expect(doc).to have_css("#new-funding-form")
      expect(doc).to have_css(".funding-table tr", text: "Newt Migration Grant")
    end

    it "renders the funding edit modal" do
      funding = create(:funding, project: project, title: "Newt Migration Grant")
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects/#{project.id}/fundings/#{funding.id}/edit"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("#edit-project-funding")
      expect(doc).to have_css("#edit-project-funding", text: "Newt Migration Grant")
    end
  end
end
