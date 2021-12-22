require "rails_helper"

RSpec.describe "app/views/projects/team_memberships/_team_memberships.html.erb", type: :view do
  describe "viewing a team membership row" do
    it "has the correct values and permissions for the columns" do
      membership = create(
        :project_team_membership,
        user: build(
          :user,
          first_name: "Mx.",
          last_name: "Nobody",
          institution: build(:institution, name: "Good School"),
          role: :docent,
        ),
        user_role: :faculty,
        institution: build(:institution, name: "Some Other School"),
        active: true,
        is_principal_investigator: false,
        can_edit_project: false,
        can_add_project_user: true,
        can_add_visit: true,
        can_receive_invoice: false,
      )
      presenter = Projects::TeamMembershipPresenter.new(membership)

      render partial: "projects/team_memberships/team_membership", locals: { team_membership: presenter }

      doc = Capybara.string(rendered)
      expect(doc).to have_css("td:nth-child(1)", text: "Mx. Nobody")
      expect(doc).to have_css("td:nth-child(2)", text: "Some Other School")
      expect(doc).to have_css("td:nth-child(3)", text: "Faculty")
      expect(doc).to have_css("td:nth-child(4)", text: "Team Member")
      expect(doc).to have_css("td:nth-child(5) img[src*='check']")
      expect(doc).to have_css("td:nth-child(6) img[src*='dot']")
      expect(doc).to have_css("td:nth-child(7) img[src*='check']")
      expect(doc).to have_css("td:nth-child(8) img[src*='dot']")
    end
  end
end
