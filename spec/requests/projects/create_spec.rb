require "rails_helper"

RSpec.describe ProjectsController, type: :request do
  describe "POST /projects" do
    it "creates a research project and advances to the team step" do
      user = create(:user, :confirmed)
      sign_in(user)

      post "/projects", params: {
        project: {
          title: "Project Title",
          abstract: "Project Abstract",
          project_type: "Research",
          start_date: "2024-06-01",
          end_date: "2024-08-31",
          discipline: "Ecology",
          involves_fish: "1",
          involves_plants_fungi_soil: "1",
          method_description: "Method Description",
          method_remove_organisms: "Yes",
          method_transfer_organisms: "Yes",
          method_study_non_native_species: "No",
          method_chemicals: "Yes",
          method_chemicals_list: "Chemicals List",
          method_soil_disturbance: "No",
          method_long_term_structures: "No"
        }
      }

      project = Project.last
      expect(response).to redirect_to(project_team_memberships_path(project, format: :html))
      expect(project.title).to eq "Project Title"
      expect(project.abstract).to eq "Project Abstract"
      expect(project).to be_project_type_research
      expect(project).to be_incomplete
      expect(project.applicant).to eq user
      expect(project.owner).to eq user
      expect(project.involves_fish).to be true
      expect(project.method_chemicals).to be true
      membership = project.team_memberships.first
      expect(membership.user).to eq user
      expect(membership).to be_active
      expect(membership.can_edit_project).to be true
    end

    it "re-renders the form when required research fields are missing" do
      user = create(:user, :confirmed)
      sign_in(user)

      expect do
        post "/projects", params: {
          project: {
            project_type: "Research",
            title: "Project Title"
          }
        }
      end.not_to change(Project, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(Capybara.string(response.body)).to have_css("#projects-new")
    end
  end
end
