require "rails_helper"

RSpec.describe Visits::UserVisitFormPresenter do
  describe "delegations" do
    subject { Visits::UserVisitFormPresenter.new(current_user: create(:user), add_visitor_partial: "team_membership") }
    it { is_expected.to delegate_method(:id).to(:form) }
    it { is_expected.to delegate_method(:errors).to(:form) }
  end

  describe "#team_member_class" do
    it "returns visitor class if user is a visitor else an empty string" do
      visit = create(:visit)
      user = create(:user)
      params = { visit_id: visit.id }
      user_visits = create_list(:user_visit, 3, visit: visit, user: user)
      presenter = Visits::UserVisitFormPresenter.new(current_user: create(:user), add_visitor_partial: "team_membership")
      presenter1 = Visits::UserVisitFormPresenter.new(current_user: create(:user), form: UserVisitForm.new(params: params), add_visitor_partial: "team_membership")

      expect(presenter.team_member_class(user)).to eq ""
      expect(presenter1.team_member_class(user)).to eq "visitor"
    end
  end

  describe "#add_visitor_link_class" do
    it "returns selected class if the passed partial name is same as add_visitor_partial" do
      presenter = Visits::UserVisitFormPresenter.new(current_user: create(:user), add_visitor_partial: "team_membership")

      expect(presenter.add_visitor_link_class("team_membership")).to eq "selected"
      expect(presenter.add_visitor_link_class("")).to eq ""
    end
  end

  describe "#user_visit_form_path" do
    it "returns user_visit_path with add_visitor_partial as query string" do
      visit = create(:visit)
      params = { visit_id: visit.id }
      presenter = Visits::UserVisitFormPresenter.new(current_user: create(:user), add_visitor_partial: "team_membership", form: UserVisitForm.new(params: params))

      expect(presenter.user_visit_form_path).to eq "/visits/#{visit.id}/user_visits?add_visitor_partial=team_membership"
    end
  end

  describe "#user_visit_form_path" do
    it "returns user_visit_path with add_visitor_partial in query string" do
      visit = create(:visit)
      params = { visit_id: visit.id }
      presenter = Visits::UserVisitFormPresenter.new(current_user: create(:user), add_visitor_partial: "team_membership", form: UserVisitForm.new(params: params))

      expect(presenter.new_user_visit_path({ add_visitor_partial: "team_member" })).to eq "/visits/#{visit.id}/user_visits/new?add_visitor_partial=team_member"
    end
  end

  describe "#user_role_options" do
    it "returns an array for user role options" do
      a = [
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
        ["Staff", "staff"]
      ]
      presenter = Visits::UserVisitFormPresenter.new(current_user: create(:user), add_visitor_partial: "team_membership")

      expect(presenter.user_role_options).to eq a
    end
  end

  describe "#user_visits" do
    it "returns an array of Visits::UserVisitPresenter for each user_visit" do
      visit = create(:visit)
      user_visits = create_list(:user_visit, 3, visit: visit)
      presenter = Visits::UserVisitsIndexPresenter.new(current_step: 2, current_user: create(:user), visit: visit)

      results = presenter.user_visits

      expect(results.map(&:id)).to eq [
        user_visits[0].id,
        user_visits[1].id,
        user_visits[2].id,
      ]

      expect(results).to all(be_instance_of Visits::UserVisitPresenter)
    end
  end

  describe "#project_team_members" do
    it "returns an array of Projects::TeamMembershipPresenter" do
      project = create(:project)
      visit = create(:visit, project: project)
      create(:project_team_membership, project: project)
      params = { visit_id: visit.id }
      presenter = Visits::UserVisitFormPresenter.new(current_user: create(:user), add_visitor_partial: "team_membership", form: UserVisitForm.new(params: params))

      expect(presenter.project_team_members).to all(be_instance_of Projects::TeamMembershipPresenter)
    end
  end

  describe "#visitor?" do
    it "returns true is the user is a visitor" do
      user = create(:user)
      visit = create(:visit)
      params = { visit_id: visit.id }
      create(:user_visit, visit: visit, user: user)
      presenter = Visits::UserVisitFormPresenter.new(current_user: user, add_visitor_partial: "team_membership", form: UserVisitForm.new(params: params))

      expect(presenter.visitor?(user)).to be_truthy
    end
  end
end
