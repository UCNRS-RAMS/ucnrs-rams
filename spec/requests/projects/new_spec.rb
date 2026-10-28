require "rails_helper"

RSpec.describe ProjectsController, type: :request do
  describe "GET /projects/new" do
    it "renders the project type options and the introduction modal" do
      sign_in(create(:user, :confirmed))

      get "/projects/new"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("body.projects-new")
      expect(doc).to have_css("form#projects-new")
      expect(doc).to have_css("input[type='radio'][name='project[project_type]']", count: 4)
      expect(doc).to have_css("input#project_project_type", visible: :all)
      expect(doc).to have_no_css("input[type='radio'][name='project[project_type]'][checked]")
      expect(doc).to have_css("#modal-content.project")
      expect(doc).to have_css("button[data-action='click->modal#close']")
    end
  end
end
