require "rails_helper"

RSpec.describe Manager::Projects::DetailController, type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }

  before { create(:reserve_personnel, user: user, reserve: reserve) }

  describe "GET /manager/reserves/:reserve_id/projects/:project_id/detail/edit" do
    %w[research meeting class].each do |project_type|
      it "renders the #{project_type} form for a #{project_type} project" do
        project = create(:project, project_type: project_type, reserve: reserve)
        sign_in(user)

        get "/manager/reserves/#{reserve.id}/projects/#{project.id}/detail/edit"

        doc = Capybara.string(response.body)
        expect(response).to be_ok
        expect(doc).to have_css("section.project-detail-edit")
        expect(doc).to have_css("form#projects-edit")
        expect(doc).to have_css("form#projects-edit div.#{project_type}")
      end
    end
  end
end
