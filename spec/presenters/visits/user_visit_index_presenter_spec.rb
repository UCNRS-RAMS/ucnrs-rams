require "rails_helper"

RSpec.describe Visits::UserVisitsIndexPresenter do
  describe "delegations" do
    subject { Visits::UserVisitsIndexPresenter.new(current_step: 1, current_user: create(:user), visit: create(:visit)) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
    it { is_expected.to delegate_method(:reserve_name).to(:visit).with_prefix }
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

  describe "#visit_date_range" do
    it "returns a date range" do
      visit = create(:visit, starts_at: "2022-10-1", ends_at: "2022-10-22")
      presenter = Visits::UserVisitsIndexPresenter.new(current_step: 2, current_user: create(:user), visit: visit)

      expect(presenter.visit_date_range).to eq "Oct 1 - 22, 2022"
    end
  end

  describe "#new_user_visit_path" do
    it "returns new_visit_user_visit_path with add_visitor_partial value in query string" do
      visit = create(:visit)
      presenter = Visits::UserVisitsIndexPresenter.new(current_step: 2, current_user: create(:user), visit: visit)

      params = {}
      params[:add_visitor_partial] = "team_member"
      expected_value = "/visits/#{visit.id}/user_visits/new?add_visitor_partial=#{params[:add_visitor_partial]}"
      expect(presenter.new_user_visit_path(params)).to eq expected_value
    end
  end

  describe "#user_role_options" do
    it "returns user role options array" do
      presenter = Visits::UserVisitsIndexPresenter.new(current_step: 2, current_user: create(:user), visit: create(:visit))

      expected_value = [
        %w[Faculty faculty],
        ["Research Scientist/Post Doc", "research_scientist"],
        ["Research Assistant (non-student/faculty/postdoc)", "research_assistant"],
        ["Graduate Student", "graduate_student"],
        ["Undergraduate Student", "undergraduate_student"],
        ["K-12 Instructor", "k_12_instructor"],
        ["K-12 Student", "k_12_student"],
        %w[Professional professional],
        %w[Other other],
        %w[Docent docent],
        %w[Volunteer volunteer],
        %w[Staff staff],
      ]

      expect(presenter.user_role_options).to eq expected_value
    end
  end
end
