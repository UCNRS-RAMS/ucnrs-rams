require "rails_helper"

RSpec.describe Projects::TeamMembershipPresenter do
  describe "delegations" do
    subject { Projects::TeamMembershipPresenter.new(build(:project_team_membership)) }
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix }
    it { is_expected.to delegate_method(:name).to(:institution).with_prefix }
  end

  describe "#user_role" do
    it "is the project team memberships user_role" do
      user = create(:user, role: :docent)
      project = create(:project)
      team_membership = create(:project_team_membership, user: user, project: project, user_role: "Faculty")
      presenter = Projects::TeamMembershipPresenter.new(team_membership)

      expect(presenter.user_role).to eq "Faculty"
    end
  end

  describe "#permissions_icon" do
    context "when the project_team_membership is active" do
      context "when the supplied value is 'Active'" do
        it "is the allowable permissions icon" do
          team_membership = create(:project_team_membership, active: true)
          presenter = Projects::TeamMembershipPresenter.new(team_membership)

          expect(presenter.permissions_icon("Active")).to eq "check.svg"
        end
      end

      context "when the supplied value is 'Edit'" do
        it "is the allowable permissions icon if the team membership has editing permissions" do
          team_membership = create(:project_team_membership, active: true, can_edit_project: true)
          presenter = Projects::TeamMembershipPresenter.new(team_membership)

          expect(presenter.permissions_icon("Edit")).to eq "check.svg"
        end

        it "is the disallowable permissions icon if the team membership does not have editing permissions" do
          team_membership = create(:project_team_membership, active: true, can_edit_project: false)
          presenter = Projects::TeamMembershipPresenter.new(team_membership)

          expect(presenter.permissions_icon("Edit")).to eq "dot.svg"
        end
      end

      context "when the supplied value is 'Book' and has booking permissions" do
        it "is the allowable permissions icon if the team membership has booking permissions" do
          team_membership = create(:project_team_membership, active: true, can_add_visit: true)
          presenter = Projects::TeamMembershipPresenter.new(team_membership)

          expect(presenter.permissions_icon("Book")).to eq "check.svg"
        end

        it "is the disallowable permissions icon if the team membership does not have booking permissions" do
          team_membership = create(:project_team_membership, active: true, can_add_visit: false)
          presenter = Projects::TeamMembershipPresenter.new(team_membership)

          expect(presenter.permissions_icon("Book")).to eq "dot.svg"
        end
      end

      context "when the supplied value is 'Invoice' and has invoicing permissions" do
        it "is the allowable permissions icon if the team membership has invoicing permissions" do
          team_membership = create(:project_team_membership, active: true, can_receive_invoice: true)
          presenter = Projects::TeamMembershipPresenter.new(team_membership)

          expect(presenter.permissions_icon("Invoice")).to eq "check.svg"
        end

        it "is the disallowable permissions icon if the team membership does not have invoicing permissions" do
          team_membership = create(:project_team_membership, active: true, can_receive_invoice: false)
          presenter = Projects::TeamMembershipPresenter.new(team_membership)

          expect(presenter.permissions_icon("Invoice")).to eq "dot.svg"
        end
      end
    end

    context "when the project_team_membership is inactive" do
      it "is the disallowable permissions icon" do
        team_membership = create(:project_team_membership, active: false)
        presenter = Projects::TeamMembershipPresenter.new(team_membership)

        expect(presenter.permissions_icon(:any_value)).to eq "dot.svg"
      end
    end
  end

  describe "#project_role" do
    it "is 'PI - Principal Investigator' if everything is true" do
      team_membership = build(
        :project_team_membership,
        is_principal_investigator: true,
        can_edit_project: true,
        can_add_project_user: true,
        can_add_visit: true,
        can_receive_invoice: true,
      )
      presenter = Projects::TeamMembershipPresenter.new(team_membership)

      expect(presenter.project_role).to eq "PI - Principal Investigator"
    end

    it "is 'Project Manager' if can_edit_project, can_add_project_user, and can_add_visit are true" do
      team_membership = build(
        :project_team_membership,
        is_principal_investigator: false,
        can_edit_project: true,
        can_add_project_user: true,
        can_add_visit: true,
        can_receive_invoice: false,
      )
      presenter = Projects::TeamMembershipPresenter.new(team_membership)

      expect(presenter.project_role).to eq "Project Manager"
    end

    it "is 'Team Member' if can_add_project_user cna can_add_visit" do
      team_membership = build(
        :project_team_membership,
        is_principal_investigator: false,
        can_edit_project: false,
        can_add_project_user: true,
        can_add_visit: true,
        can_receive_invoice: false,
      )
      presenter = Projects::TeamMembershipPresenter.new(team_membership)

      expect(presenter.project_role).to eq "Team Member"
    end

    it "is 'Billing' if can_add_visit and can_receive_invoice are true" do
      team_membership = build(
        :project_team_membership,
        is_principal_investigator: false,
        can_edit_project: false,
        can_add_project_user: false,
        can_add_visit: true,
        can_receive_invoice: true,
      )
      presenter = Projects::TeamMembershipPresenter.new(team_membership)

      expect(presenter.project_role).to eq "Billing"
    end

    it "is nil if none of the above apply" do
      team_membership = build(
        :project_team_membership,
        is_principal_investigator: false,
        can_edit_project: true,
        can_add_project_user: false,
        can_add_visit: true,
        can_receive_invoice: true,
      )
      presenter = Projects::TeamMembershipPresenter.new(team_membership)

      expect(presenter.project_role).to be_nil
    end
  end

  describe "#permissions" do
    it "is an array of permission names" do
      team_membership = build(:project_team_membership)
      presenter = Projects::TeamMembershipPresenter.new(team_membership)

      expect(presenter.permissions).to eq [
        "Active",
        "Edit",
        "Book",
        "Invoice",
      ]
    end
  end
end
