require "rails_helper"

RSpec.describe Projects::UsersController, type: :request do
  describe "POST /projects/:project_id/users" do
    it "creates a user and adds them to the project team" do
      country = create(:country, name: "Country 1")
      state = create(:state, name: "State 1", country: country)
      institution = create(:institution, name: "MIT")
      user = create(:user, :confirmed)
      project = create(:project)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_add_project_user: true,
      )
      sign_in(user)

      expect do
        post "/projects/#{project.id}/users", params: {
          user: {
            first_name: "First",
            last_name: "Last",
            email: "first@last.test",
            phone_number: "111-111-1111",
            emergency_contact_full_name: "name 1",
            emergency_contact_phone_number: "222-222-2222",
            institution_id: institution.id,
            institution_selection_type: "institution",
            user_role: "Docent",
            project_role: ProjectTeamMembership::TEAM_MEMBER_ROLE,
            address_country_id: country.id,
            address_line_1: "123 main",
            address_city: "city 123",
            address_state_id: state.id,
            address_postal_code: "91234"
          }
        }
      end.to change(User, :count).by(1)

      created_user = User.find_by(email: "first@last.test")
      expect(response).to redirect_to(project_team_memberships_path(project))
      expect(created_user.first_name).to eq "First"
      expect(created_user.last_name).to eq "Last"
      expect(created_user.institution).to eq institution
      membership = project.team_memberships.find_by(user: created_user)
      expect(membership).to be_present
      expect(membership).to be_active
      expect(membership.can_add_project_user).to be true
      expect(membership.can_edit_project).to be false
      expect(membership.is_principal_investigator).to be false
    end
  end
end
