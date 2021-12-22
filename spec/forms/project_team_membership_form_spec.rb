require "rails_helper"

RSpec.describe ProjectTeamMembershipForm, type: :model do
  describe "validations" do
    let(:roles) { ProjectTeamMembership::PROJECT_ROLES }

    describe "create" do
      subject { ProjectTeamMembershipForm.new(project: build(:project)) }

      it { is_expected.to validate_inclusion_of(:project_role).in_array(roles) }
      it { is_expected.to validate_presence_of(:institution_id) }
    end

    describe "edit" do
      let(:membership) { create(:project_team_membership) }
      subject { ProjectTeamMembershipForm.new(params: { id: membership.id }) }

      it { is_expected.not_to validate_inclusion_of(:project_role).in_array(roles) }
      it { is_expected.to validate_presence_of(:institution_id) }
    end
  end

  describe "when validating params" do
    it "collates errors when creating a new membership" do
      membership = create(:project_team_membership)
      form = ProjectTeamMembershipForm.new(
        project: membership.project,
        params: {
          user_id: membership.user.id,
          project_role: "",
        }
      )

      form.validate

      expect(form.errors[:full_name]).to eq ["already on this team"]
      expect(form.errors[:project_role]).to eq ["must select an option"]
    end

    it "collates errors when saving an existing membership" do
      membership = create(:project_team_membership)
      form = ProjectTeamMembershipForm.new(
        project: membership.project,
        params: {
          id: membership.id,
          user_id: membership.user.id,
          project_role: "",
          institution_id: "",
        }
      )

      form.validate

      expect(form.errors[:institution_name]).to eq ["can't be blank"]
    end

    it "does not allow users that don't exist" do
      membership = create(:project_team_membership)
      form = ProjectTeamMembershipForm.new(
        project: membership.project,
        params: {
          user_id: 234725874837538745,
        }
      )

      form.validate

      expect(form.errors[:user]).to eq ["must exist"]
    end
  end

  describe "initialize" do
    it "tries to load the ProjectTeamMembership with id of params[:id]" do
      ptm = create(:project_team_membership)

      presenter = ProjectTeamMembershipForm.new(
        project: build(:project),
        params: { id: ptm.id }
      )

      expect(presenter.project_team_membership).to eq ptm
    end

    it "initializes a new ProjectTeamMembership if the id is not available" do
      presenter = ProjectTeamMembershipForm.new(
        project: build(:project),
        params: { id: -1 },
      )

      expect(presenter.project_team_membership).to_not be_persisted
    end
  end

  describe "delegations" do
    subject { ProjectTeamMembershipForm.new(project: build(:project)) }
    it { is_expected.to delegate_missing_methods_to(:project_team_membership) }
  end

  describe "#project_role=" do
    it "sets permissions for PRINCIPAL_INVESTIGATOR_ROLE" do
      presenter = ProjectTeamMembershipForm.new(project: build(:project))

      presenter.project_role = ProjectTeamMembership::PRINCIPAL_INVESTIGATOR_ROLE

      expect(presenter.is_principal_investigator).to be true
      expect(presenter.can_edit_project).to be true
      expect(presenter.can_add_project_user).to be true
      expect(presenter.can_add_visit).to be true
      expect(presenter.can_receive_invoice).to be true
    end

    it "sets permissions for PROJECT_MANAGER_ROLE" do
      presenter = ProjectTeamMembershipForm.new(project: build(:project))

      presenter.project_role = ProjectTeamMembership::PROJECT_MANAGER_ROLE

      expect(presenter.is_principal_investigator).to be false
      expect(presenter.can_edit_project).to be true
      expect(presenter.can_add_project_user).to be true
      expect(presenter.can_add_visit).to be true
      expect(presenter.can_receive_invoice).to be false
    end

    it "sets permissions for TEAM_MEMBER_ROLE" do
      presenter = ProjectTeamMembershipForm.new(project: build(:project))

      presenter.project_role = ProjectTeamMembership::TEAM_MEMBER_ROLE

      expect(presenter.is_principal_investigator).to be false
      expect(presenter.can_edit_project).to be false
      expect(presenter.can_add_project_user).to be true
      expect(presenter.can_add_visit).to be true
      expect(presenter.can_receive_invoice).to be false
    end

    it "sets permissions for BILLING_ROLE" do
      presenter = ProjectTeamMembershipForm.new(project: build(:project))

      presenter.project_role = ProjectTeamMembership::BILLING_ROLE

      expect(presenter.is_principal_investigator).to be false
      expect(presenter.can_edit_project).to be false
      expect(presenter.can_add_project_user).to be false
      expect(presenter.can_add_visit).to be true
      expect(presenter.can_receive_invoice).to be true
    end

    it "sets permissions for anything else" do
      presenter = ProjectTeamMembershipForm.new(project: build(:project))

      presenter.project_role = "dunno, I'm an admin, lol"

      expect(presenter.is_principal_investigator).to be false
      expect(presenter.can_edit_project).to be false
      expect(presenter.can_add_project_user).to be false
      expect(presenter.can_add_visit).to be false
      expect(presenter.can_receive_invoice).to be false
    end
  end
end
