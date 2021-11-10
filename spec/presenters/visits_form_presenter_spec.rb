require "rails_helper"

RSpec.describe VisitsFormPresenter do
  describe "delegations" do
    let(:user) { build(:user) }
    let(:reserve) do
      create :reserve,
        special_needs_statement: "Goodbye",
        reserve_alert_message_enabled: true,
        reserve_alert_message: "Hello"
    end
    let(:form) { VisitForm.new(params: { reserve_id: create(:reserve).id }) }
    subject { VisitsFormPresenter.new(user: user) }

    it { is_expected.to delegate_method(:visit).to(:form) }
    it { is_expected.to delegate_method(:start_date).to(:form) }
    it { is_expected.to delegate_method(:end_date).to(:form) }
    it { is_expected.to delegate_method(:start_time).to(:form) }
    it { is_expected.to delegate_method(:end_time).to(:form) }
    it { is_expected.to delegate_method(:reserve).to(:visit) }
    it { is_expected.to delegate_method(:special_needs_statement).to(:reserve) }
    it { is_expected.to delegate_method(:special_needs_statement).to(:reserve) }
  end

  describe "project_type_options" do
    it "transforms the options to have dashes instead of spaces" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      expect(presenter.project_type_options).to eq [
        "research",
        "university_class",
        "meeting_or_conference",
        "public_use",
      ]
    end
  end

  describe "#projects" do
    it "initializes a Visits::ProjectsPresenter" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      visit_projects_presenter = presenter.projects

      expect(visit_projects_presenter.projects).to eq [Project.blank]
      expect(visit_projects_presenter.project_id).to be_nil
      expect(visit_projects_presenter.project_type).to be_nil
    end
  end

  describe "#reserves" do
    it "initializes a Visits::ReservesPresenter" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      visit_reserves_presenter = presenter.reserves

      expect(visit_reserves_presenter.reserves).to eq [Reserve.blank]
      expect(visit_reserves_presenter.reserve_id).to be_nil
      expect(visit_reserves_presenter.project_type).to be_nil
    end
  end

  describe "#public_use_categories" do
    it "returns the Visit's public_use_categories" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      expect(presenter.public_use_categories)
        .to eq Visit.public_use_categories.keys
    end
  end
end
