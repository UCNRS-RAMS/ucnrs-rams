require "rails_helper"

RSpec.describe Visits::UserVisitPresenter do
  describe "delegations" do
    subject { Visits::UserVisitPresenter.new(build(:user_visit)) }
    it { is_expected.to delegate_missing_methods_to(:user_visit) }
  end

  describe "#user_visit_type" do
    context "when user is a team member" do
      it "returns the users' project role" do
        team_membership = create(:project_team_membership, :project_manager, active: true)
        visit = create(:visit, project_id: team_membership.project_id)
        user_visit = create(:user_visit, user_id: team_membership.user_id, visit_id: visit.id)
        presenter = Visits::UserVisitPresenter.new(user_visit)

        expect(presenter.user_visit_type).to eq "Project Manager"
      end
    end

    context "when user is a guest" do
      it "returns user icon" do
        user_visit = create(:user_visit, user_id: create(:user).id)
        presenter = Visits::UserVisitPresenter.new(user_visit)

        expect(presenter.user_visit_type).to include "icon-user-navbar"
        expect(presenter.user_visit_type).to include ".svg"
      end
    end

    context "when user is a group" do
      it "returns users icon" do
        user_visit = create(:user_visit, user_id: create(:user, id: 1).id)
        presenter = Visits::UserVisitPresenter.new(user_visit)

        expect(presenter.user_visit_type).to include "icon-users"
        expect(presenter.user_visit_type).to include ".svg"
      end
    end
  end

  describe "#user_full_name" do
    context "when user is a team member" do
      it "returns the users' full name" do
        user = create(:user, first_name: "First", last_name: "Last")
        team_membership = create(:project_team_membership, :project_manager, active: true,
          user: user)
        visit = create(:visit, project_id: team_membership.project_id)
        user_visit = create(:user_visit, user_id: team_membership.user_id, visit_id: visit.id)
        presenter = Visits::UserVisitPresenter.new(user_visit)

        expect(presenter.user_full_name).to eq "First Last"
      end
    end

    context "when user is a guest" do
      it "returns users' full name" do
        user = create(:user, first_name: "First", last_name: "Last")
        user_visit = create(:user_visit, user: user)
        presenter = Visits::UserVisitPresenter.new(user_visit)

        expect(presenter.user_full_name).to eq "First Last"
      end
    end

    context "when user is a group" do
      it "returns group count" do
        user_visit = create(:user_visit, user: create(:user, id: 1), count: 10)
        presenter = Visits::UserVisitPresenter.new(user_visit)

        expect(presenter.user_full_name).to eq "Group of 10"
      end
    end
  end

  describe "#date_range" do
    it "returns the date range" do
      arrives_at = Time.current
      departs_at = Time.current + 1.day
      presenter = Visits::UserVisitPresenter.new(create(:user_visit, arrives_at: arrives_at,
        departs_at: departs_at))

      expect(presenter.date_range).to eq "#{arrives_at.strftime('%m/%d/%Y')} - #{departs_at.strftime('%m/%d/%Y')}"
    end
  end

  describe "#user_role" do
    it "return user role as in user_visit" do
      user_visit = create(:user_visit)
      presenter = Visits::UserVisitPresenter.new(user_visit)
      expect(presenter.user_role).to eq "Faculty"
    end
  end

  describe "#edit_user_visit_form_path" do
    it "returns edit_user_visit_path" do
      user_visit = create(:user_visit)
      presenter = Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.edit_user_visit_form_path).to eq "/user_visits/#{user_visit.id}/edit"
    end
  end

  describe "#user_visit_form_path" do
    it "returns user_visit_path" do
      user_visit = create(:user_visit)
      presenter = Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.user_visit_form_path).to eq "/user_visits/#{user_visit.id}"
    end
  end

  describe "#guest_user?" do
    it "returns true if the user_id is 1 and guest_name is present" do
      user = create(:user, id: 1)
      user_visit = create(:user_visit, user: user, guest_name: "Guest name")
      presenter = Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.guest_user?).to be_truthy
    end

    it "returns false if guest_name is not present" do
      user = create(:user, id: 1)
      user_visit = create(:user_visit, user: user, guest_name: nil)
      presenter = Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.guest_user?).to be_falsey
    end

    it "returns false if user_id is not 1" do
      user = create(:user, id: 2)
      user_visit = create(:user_visit, user: user, guest_name: "Guest Name")
      presenter = Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.guest_user?).to be_falsey
    end
  end

  describe "#group_user?" do
    it "returns true if the user_id is 1 and guest_name is blank" do
      user = create(:user, id: 1)
      user_visit = create(:user_visit, user: user, guest_name: nil)
      presenter = Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.group_user?).to be_truthy
    end

    it "returns false if guest_name is present" do
      user = create(:user, id: 1)
      user_visit = create(:user_visit, user: user, guest_name: "Guest name")
      presenter = Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.group_user?).to be_falsey
    end

    it "returns false if user_id is not 1" do
      user = create(:user, id: 2)
      user_visit = create(:user_visit, user: user)
      presenter = Visits::UserVisitPresenter.new(user_visit)

      expect(presenter.group_user?).to be_falsey
    end
  end

  describe "#project_role" do
    context "when user is a team member" do
      it "returns the users' project role" do
        team_membership = create(:project_team_membership, :project_manager, active: true)
        visit = create(:visit, project_id: team_membership.project_id)
        user_visit = create(:user_visit, user_id: team_membership.user_id, visit_id: visit.id)
        presenter = Visits::UserVisitPresenter.new(user_visit)

        expect(presenter.user_visit_type).to eq "Project Manager"
      end
    end
  end

  describe "#date_of_use" do
    it "return visit overall date range" do
      visit = create(:visit, starts_at: "20 sep 2022", ends_at: "22 sep 2022")
      user = create(:user, :confirmed)
      show_presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: user)

      expect(show_presenter.visit_date_range).to eq "Sep 20, 2022 - Sep 22, 2022"
    end
  end
end
