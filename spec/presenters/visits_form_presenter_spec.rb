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

  describe "#time_options" do
    it "gives options for each half hour" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      options = presenter.time_options

      expect(options.map(&:value)).to eq [
        "00:00",
        "00:30",
        "01:00",
        "01:30",
        "02:00",
        "02:30",
        "03:00",
        "03:30",
        "04:00",
        "04:30",
        "05:00",
        "05:30",
        "06:00",
        "06:30",
        "07:00",
        "07:30",
        "08:00",
        "08:30",
        "09:00",
        "09:30",
        "10:00",
        "10:30",
        "11:00",
        "11:30",
        "12:00",
        "12:30",
        "13:00",
        "13:30",
        "14:00",
        "14:30",
        "15:00",
        "15:30",
        "16:00",
        "16:30",
        "17:00",
        "17:30",
        "18:00",
        "18:30",
        "19:00",
        "19:30",
        "20:00",
        "20:30",
        "21:00",
        "21:30",
        "22:00",
        "22:30",
        "23:00",
        "23:30",
      ]
      expect(options.map(&:human)).to eq [
        "12:00 AM",
        "12:30 AM",
        "1:00 AM",
        "1:30 AM",
        "2:00 AM",
        "2:30 AM",
        "3:00 AM",
        "3:30 AM",
        "4:00 AM",
        "4:30 AM",
        "5:00 AM",
        "5:30 AM",
        "6:00 AM",
        "6:30 AM",
        "7:00 AM",
        "7:30 AM",
        "8:00 AM",
        "8:30 AM",
        "9:00 AM",
        "9:30 AM",
        "10:00 AM",
        "10:30 AM",
        "11:00 AM",
        "11:30 AM",
        "12:00 PM",
        "12:30 PM",
        "1:00 PM",
        "1:30 PM",
        "2:00 PM",
        "2:30 PM",
        "3:00 PM",
        "3:30 PM",
        "4:00 PM",
        "4:30 PM",
        "5:00 PM",
        "5:30 PM",
        "6:00 PM",
        "6:30 PM",
        "7:00 PM",
        "7:30 PM",
        "8:00 PM",
        "8:30 PM",
        "9:00 PM",
        "9:30 PM",
        "10:00 PM",
        "10:30 PM",
        "11:00 PM",
        "11:30 PM",
      ]
    end
  end
end
