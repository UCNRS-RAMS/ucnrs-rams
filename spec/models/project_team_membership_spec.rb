require "rails_helper"

RSpec.describe ProjectTeamMembership, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:institution) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user_role) }
    it { is_expected.to validate_booleanish_values(:active) }
    it { is_expected.to validate_booleanish_values(:is_principal_investigator) }
    it { is_expected.to validate_booleanish_values(:can_edit_project) }
    it { is_expected.to validate_booleanish_values(:can_add_project_user) }
    it { is_expected.to validate_booleanish_values(:can_add_visit) }
    it { is_expected.to validate_booleanish_values(:can_receive_invoice) }

    describe "scoping unique users to projects" do
      it "does not allow a user to be added to the same project twice" do
        project_team_member1 = create(:project_team_membership)
        project_team_member2 = build(:project_team_membership, project: project_team_member1.project, user: project_team_member1.user)

        expect(project_team_member2).not_to be_valid
      end
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:id).to(:project).with_prefix }
  end

  it do 
    is_expected.to define_enum_for(:user_role)
      .with_values(
        no_selection: "No selection",
        faculty: "Faculty",
        research_scientist: "Research Scientist/Post Doc",
        research_assistant: "Research Assistant (non-student/faculty/postdoc)",
        graduate_student: "Graduate Student",
        undergraduate_student: "Undergraduate Student",
        k_12_instructor: "K-12 Instructor",
        k_12_student: "K-12 Student",
        professional: "Professional",
        other: "Other",
        docent: "Docent",
        volunteer: "Volunteer",
        reserve_staff: "Staff",
      ).backed_by_column_of_type(:string)
  end

  describe ".by_project_role" do
    it "sorts members by their permissions: PI, PM, Member, Billing" do
      member = create(:project_team_membership, :team_member)
      inactive_pi = create(:project_team_membership, :principal_investigator, active: false)
      billing = create(:project_team_membership, :billing)
      someone_else = create(
        :project_team_membership,
        is_principal_investigator: true,
        can_edit_project: false,
        can_add_project_user: false,
        can_add_visit: false,
        can_receive_invoice: true,
      )
      project_manager = create(:project_team_membership, :project_manager)
      principal_investigator = create(:project_team_membership, :principal_investigator)

      members = ProjectTeamMembership.by_project_role

      expect(members.map(&:id)).to eq [
        principal_investigator,
        project_manager,
        member,
        billing,
        someone_else,
        inactive_pi,
      ].map(&:id)
    end
  end

  describe ".principal_investigators" do
    it "returns records of team members that are principal investigators" do
      member = create(:project_team_membership, :team_member)
      pi = create(:project_team_membership, :principal_investigator)
      billing = create(:project_team_membership, :billing)
      project_manager = create(:project_team_membership, :project_manager)

      members = ProjectTeamMembership.principal_investigators

      expect(members).to eq [pi]
    end
  end

  describe ".can_receive_invoice" do
    it "returns records of team members that have can recieve invoice" do
      reciever = create(:project_team_membership, can_receive_invoice: true)
      create(:project_team_membership, can_receive_invoice: false)

      members = ProjectTeamMembership.can_receive_invoice

      expect(members).to eq [reciever]
    end
  end

  describe ".is_active" do
    it "returns only active team membership" do
      active_member = create(:project_team_membership, active: true)
      inactive_member = create(:project_team_membership, active: false)

      members = ProjectTeamMembership.is_active

      expect(members).to eq [active_member]
    end
  end
end
