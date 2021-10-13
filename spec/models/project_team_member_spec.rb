require "rails_helper"

RSpec.describe ProjectTeamMember, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:institution).optional(true) }
  end

  describe "validations" do
    describe "scoping unique users to projects" do
      it "does not allow a user to be added to the same project twice" do
        project_team_member1 = create(:project_team_member)
        project_team_member2 = build(:project_team_member, project: project_team_member1.project, user: project_team_member1.user)

        expect(project_team_member2).not_to be_valid
      end
    end
  end
end
