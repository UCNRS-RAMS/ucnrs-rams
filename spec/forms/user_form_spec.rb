require "rails_helper"

RSpec.describe UserForm, type: :model do
  describe "validations" do
    it do
      is_expected.to validate_inclusion_of(:project_role)
        .in_array(ProjectTeamMembership::PROJECT_ROLES)
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_missing_methods_to(:user) }
  end

  describe "when validating params" do
    it "collates errors when creating a new user" do
      form = UserForm.new(
        params: {
          first_name: "",
          institution_id: "",
          institution_name: "",
          last_name: "Moustache",
          email: "mister@moustache.test",
          user_role: "Other",
          project_role: "",
        }
      )

      form.validate

      expect(form.errors[:first_name]).to eq [I18n.t("activerecord.errors.messages.blank")]
      expect(form.errors[:project_role]).to eq ["is not included in the list"]
      expect(form.errors[:institution_name]).to eq [I18n.t("activerecord.errors.messages.blank"), "must exist"]
    end

    it "cannot create users that already exist" do
      project = create(:project)
      user = create(:user, email: "already@exists.test")
      form = UserForm.new(
        params: {
          email: "already@exists.test",
        }
      )

      form.validate

      expect(form.errors[:email]).to eq ["has already been taken"]
    end
  end

  describe "#initialize" do
    it "initializes a new User from params" do
      institution = create(:institution, name: "Foo U")
      form = UserForm.new(
        applicant: build(:user),
        project: build(:project),
        params: {
          first_name: "Mister",
          last_name: "Moustache",
          institution_id: institution.id,
          institution_name: institution.name,
          email: "mister@moustache.test",
          user_role: "Other",
          project_role: ProjectTeamMembership::PROJECT_MANAGER_ROLE,
        }
      )

      expect(form.user).to_not be_persisted
      expect(form.user).to have_attributes(
        first_name: "Mister",
        last_name: "Moustache",
        institution_id: institution.id,
        email: "mister@moustache.test",
        role: "other",
      )
    end

    it "assigns the user's role attribute from the user_role param" do
      form = UserForm.new(
        params: {
          user_role: "Faculty"
        }
      )

      expect(form.user).to have_attributes(role: "faculty")
    end

    it "initializes a ProjectTeamMembership" do
      project = create(:project)
      form = UserForm.new(
        project: project,
        params: {
          project_role: ProjectTeamMembership::PRINCIPAL_INVESTIGATOR_ROLE
        },
      )

      membership = form.project_team_membership

      expect(membership).to_not be_persisted
      expect(membership).to have_attributes(
        user: form.user,
        project: project,
        active: true,
        is_principal_investigator: true,
        can_add_project_user: true,
        can_add_visit: true,
        can_edit_project: true,
        can_receive_invoice: true,
      )
    end

    describe "assigning email" do
      it "assigns the email address supplied in params if it exists" do
        form = UserForm.new(
          params: {
            email: "present@email.test",
          }
        )

        expect(form.email).to eq "present@email.test"
      end

      it "does not assign an email if there is no applicant supplied" do
        form = UserForm.new(
          params: { email: "" }
        )

        expect(form.email).to be_blank
      end
    end
  end

  describe "#save" do
    it "saves the user if there are no errors" do
      institution = create(:institution)
      us = create(:country, name: "United States")
      ca = create(:state, name: "California", country: us)
      form = UserForm.new(
        applicant: create(:user),
        project: create(:project),
        params: {
          first_name: "Mister",
          last_name: "Moustache",
          institution_id: institution.id,
          institution_name: institution.name,
          email: "mister@moustache.test",
          user_role: "Other",
          project_role: ProjectTeamMembership::PRINCIPAL_INVESTIGATOR_ROLE,
          phone_number: "111-111-1111",
          emergency_contact_full_name: "name 1",
          emergency_contact_phone_number: "222-222-2222",
          address_line_1: "123 main",
          address_city: "city 123",
          address_postal_code: "91234",
          address_state_id: ca.id,
          address_country_id: us.id,
        }
      )

      result = form.save

      expect(result).to be_truthy
      expect(form.user).to be_persisted
      expect(form.user).to have_attributes(
        first_name: "Mister",
        last_name: "Moustache",
        institution_id: institution.id,
        email: "mister@moustache.test",
        role: "other",
        phone_number: "111-111-1111",
        emergency_contact_full_name: "name 1",
        emergency_contact_phone_number: "222-222-2222",
        address_line_1: "123 main",
        address_city: "city 123",
        address_postal_code: "91234",
        address_state_id: ca.id,
        address_country_id: us.id,
      )
    end

    it "makes sure errors are visible when save fails" do
      form = UserForm.new(
        applicant: build(:user),
        project: build(:project),
        params: {
          first_name: "Mister",
          last_name: "Moustache",
          email: "mister@moustache.test",
          user_role: "Other",
          project_role: ProjectTeamMembership::PROJECT_MANAGER_ROLE,
        }
      )

      result = form.save

      expect(result).to be_falsy
      expect(form.user).to_not be_persisted
      expect(form.errors).to be_present
    end

    it "creates a project_team_membership between the user and the project" do
      applicant = create(:user)
      project = create(:project)
      institution = create(:institution)
      us = create(:country, name: "United States")
      ca = create(:state, name: "California", country: us)
      form = UserForm.new(
        applicant: applicant,
        project: project,
        params: {
          first_name: "Mister",
          last_name: "Moustache",
          institution_id: institution.id,
          institution_name: institution.name,
          email: "mister@moustache.test",
          user_role: "Other",
          project_role: ProjectTeamMembership::PRINCIPAL_INVESTIGATOR_ROLE,
          phone_number: "111-111-1111",
          emergency_contact_full_name: "name 1",
          emergency_contact_phone_number: "222-222-2222",
          address_line_1: "123 main",
          address_city: "city 123",
          address_postal_code: "91234",
          address_state_id: ca.id,
          address_country_id: us.id,
        }
      )

      form.save

      new_user = form.user
      new_membership = form.project_team_membership
      expect(new_membership).to be_persisted
      expect(new_membership).to have_attributes(
        project_id: project.id,
        user_id: new_user.id,
        institution_id: new_user.institution.id,
        user_role: new_user.role,
        is_principal_investigator: true,
        can_edit_project: true,
        can_add_project_user: true,
        can_add_visit: true,
        can_receive_invoice: true,
      )
    end

    it "logs errors if the transaction is rolled back" do
      form = UserForm.new
      allow(Rails.logger).to receive(:error)

      result = form.save

      expect(Rails.logger).to have_received(:error)
      expect(result).to be false
    end
  end

  describe "#project_role=" do
    it "sets permissions for PRINCIPAL_INVESTIGATOR_ROLE" do
      form = UserForm.new

      form.project_role = ProjectTeamMembership::PRINCIPAL_INVESTIGATOR_ROLE

      expect(form.is_principal_investigator).to be true
      expect(form.can_edit_project).to be true
      expect(form.can_add_project_user).to be true
      expect(form.can_add_visit).to be true
      expect(form.can_receive_invoice).to be true
    end

    it "sets permissions for PROJECT_MANAGER_ROLE" do
      form = UserForm.new

      form.project_role = ProjectTeamMembership::PROJECT_MANAGER_ROLE

      expect(form.is_principal_investigator).to be false
      expect(form.can_edit_project).to be true
      expect(form.can_add_project_user).to be true
      expect(form.can_add_visit).to be true
      expect(form.can_receive_invoice).to be false
    end

    it "sets permissions for TEAM_MEMBER_ROLE" do
      form = UserForm.new

      form.project_role = ProjectTeamMembership::TEAM_MEMBER_ROLE

      expect(form.is_principal_investigator).to be false
      expect(form.can_edit_project).to be false
      expect(form.can_add_project_user).to be true
      expect(form.can_add_visit).to be true
      expect(form.can_receive_invoice).to be false
    end

    it "sets permissions for BILLING_ROLE" do
      form = UserForm.new

      form.project_role = ProjectTeamMembership::BILLING_ROLE

      expect(form.is_principal_investigator).to be false
      expect(form.can_edit_project).to be false
      expect(form.can_add_project_user).to be false
      expect(form.can_add_visit).to be true
      expect(form.can_receive_invoice).to be true
    end

    it "sets permissions for anything else" do
      form = UserForm.new

      form.project_role = "foo"

      expect(form.is_principal_investigator).to be false
      expect(form.can_edit_project).to be false
      expect(form.can_add_project_user).to be false
      expect(form.can_add_visit).to be false
      expect(form.can_receive_invoice).to be false
    end
  end
end
