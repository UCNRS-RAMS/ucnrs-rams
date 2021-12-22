require "rails_helper"

RSpec.describe Projects::TeamMembershipEditPresenter do
  describe "delegations" do
    subject { Projects::TeamMembershipEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:id).to(:form) }
    it { is_expected.to delegate_method(:errors).to(:form) }
  end

  describe "editing_team_membership" do
    it "returns a Projects::TeamMembershipPresenter from the id on the form" do
      first = create(:project_team_membership)
      second = create(:project_team_membership)
      form = ProjectTeamMembershipForm.new(params: { id: second.id })
      presenter = Projects::TeamMembershipEditPresenter.new(form: form)

      result = presenter.editing_team_membership

      expect(result).to be_a Projects::TeamMembershipPresenter
      expect(result.id).to eq second.id
    end
  end

  describe "user_full_name" do
    it "returns the name of the user based on the team_membership" do
      membership = create(
        :project_team_membership,
        user: create(:user, first_name: "First", last_name: "Last")
      )
      form = ProjectTeamMembershipForm.new(params: { id: membership.id })
      presenter = Projects::TeamMembershipEditPresenter.new(form: form)

      expect(presenter.user_full_name).to eq "First Last"
    end
  end

  describe "institution_name" do
    it "returns the name of the institution based on the team_membership" do
      membership = create(
        :project_team_membership,
        institution: create(:institution, name: "Fun School")
      )
      form = ProjectTeamMembershipForm.new(params: { id: membership.id })
      presenter = Projects::TeamMembershipEditPresenter.new(form: form)

      expect(presenter.institution_name).to eq "Fun School"
    end
  end

  describe "user_role_options" do
    it "puts the role option (not incl. 'No Selection') into a useful array" do
      form = ProjectTeamMembershipForm.new()
      presenter = Projects::TeamMembershipEditPresenter.new(form: form)

      expect(presenter.user_role_options).to eq [
        ["Faculty", "faculty"],
        ["Research Scientist/Post Doc", "research_scientist"],
        ["Research Assistant (non-student/faculty/postdoc)", "research_assistant"],
        ["Graduate Student", "graduate_student"],
        ["Undergraduate Student", "undergraduate_student"],
        ["K-12 Instructor", "k_12_instructor"],
        ["K-12 Student", "k_12_student"],
        ["Professional", "professional"],
        ["Other", "other"],
        ["Docent", "docent"],
        ["Volunteer", "volunteer"],
        ["Staff", "staff"],
      ]
    end
  end
end
