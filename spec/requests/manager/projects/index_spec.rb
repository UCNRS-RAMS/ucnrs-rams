require "rails_helper"

RSpec.describe Manager::ProjectsController, type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }

  before { create(:reserve_personnel, user: user, reserve: reserve) }

  describe "GET /manager/reserves/:reserve_id/projects" do
    it "paginates the projects ten at a time" do
      25.times do |n|
        project = create(:project, title: "Project #{n}")
        create(
          :visit,
          project: project,
          reserve: reserve,
          start_date: Time.zone.today,
          end_date: Date.tomorrow,
        )
      end
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/projects"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("tr.project", count: 10)
      expect(doc).to have_css("nav.pagination")
      expect(doc).to have_css("span.page.current", text: "1")

      get "/manager/reserves/#{reserve.id}/projects", params: { page: 3 }

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("tr.project", count: 5)
      expect(doc).to have_css("span.page.current", text: "3")
    end

    it "does not let a user who is not a manager of the reserve list the projects" do
      non_manager = create(:user, :confirmed)
      create(:reserve_personnel, user: non_manager, reserve: create(:reserve))
      sign_in(non_manager)

      get "/manager/reserves/#{reserve.id}/projects"

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq I18n.t("manager.not_a_manager_of_reserve")
    end
  end
end
