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

    it { is_expected.to delegate_method(:project_title).to(:form) }
    it { is_expected.to delegate_method(:reserve_name).to(:form) }
    it { is_expected.to delegate_method(:id).to(:form) }
    it { is_expected.to delegate_method(:visit).to(:form) }
    it { is_expected.to delegate_method(:start_date).to(:form) }
    it { is_expected.to delegate_method(:end_date).to(:form) }
    it { is_expected.to delegate_method(:start_time).to(:form) }
    it { is_expected.to delegate_method(:end_time).to(:form) }
    it { is_expected.to delegate_method(:reserve).to(:visit) }
    it { is_expected.to delegate_method(:special_needs_statement).to(:reserve) }
    it { is_expected.to delegate_method(:special_needs_statement).to(:reserve) }
    it { is_expected.to delegate_method(:editing).to(:form) }
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
    it "gives options for each hour" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      options = presenter.time_options

      expect(options.map(&:value)).to eq [
        "00:00",
        "01:00",
        "02:00",
        "03:00",
        "04:00",
        "05:00",
        "06:00",
        "07:00",
        "08:00",
        "09:00",
        "10:00",
        "11:00",
        "12:00",
        "13:00",
        "14:00",
        "15:00",
        "16:00",
        "17:00",
        "18:00",
        "19:00",
        "20:00",
        "21:00",
        "22:00",
        "23:00",
      ]
      expect(options.map(&:human)).to eq [
        "12:00 AM",
        "1:00 AM",
        "2:00 AM",
        "3:00 AM",
        "4:00 AM",
        "5:00 AM",
        "6:00 AM",
        "7:00 AM",
        "8:00 AM",
        "9:00 AM",
        "10:00 AM",
        "11:00 AM",
        "12:00 PM",
        "1:00 PM",
        "2:00 PM",
        "3:00 PM",
        "4:00 PM",
        "5:00 PM",
        "6:00 PM",
        "7:00 PM",
        "8:00 PM",
        "9:00 PM",
        "10:00 PM",
        "11:00 PM",
      ]
    end
  end

  describe "#project_type_partial_path" do
    it "should return project_options_partial_path" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      expect(presenter.project_type_partial_path).to eq "visits/project_type"
    end
  end

  describe "#project_partial_path" do
    it "should return 'shared/visits/project' when editing" do
      form = VisitForm.new(params: { reserve_id: create(:reserve).id }, editing: true)
      presenter = VisitsFormPresenter.new(user: build(:user), form: form)
      
      expect(presenter.project_partial_path).to eq "shared/visits/project"
    end

    it "should return 'visits/project' when not editing" do
      form = VisitForm.new(params: { reserve_id: create(:reserve).id }, editing: false)
      presenter = VisitsFormPresenter.new(user: build(:user), form: form)

      expect(presenter.project_partial_path).to eq "visits/project"
    end
  end

  describe "#save_partial_path" do
    it "should return save_partial_path" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      expect(presenter.save_partial_path).to eq "visits/save"
    end
  end

  describe "#reserve_partial_path" do
    it "should return 'shared/visits/reserve' when editing" do
      form = VisitForm.new(params: { reserve_id: create(:reserve).id }, editing: true)
      presenter = VisitsFormPresenter.new(user: build(:user), form: form)

      expect(presenter.reserve_partial_path).to eq "shared/visits/reserve"
    end

    it "should return 'visits/reserve' when not editing" do
      form = VisitForm.new(params: { reserve_id: create(:reserve).id }, editing: false)
      presenter = VisitsFormPresenter.new(user: build(:user), form: form)

      expect(presenter.reserve_partial_path).to eq "visits/reserve"
    end
  end

  describe "#project_summary_path" do
    it "should return project_path" do
      form = VisitForm.new(params: { project_id: create(:project).id })
      presenter = VisitsFormPresenter.new(user: build(:user), form: form)

      result = "/projects/#{form.project_id}"
      
      expect(presenter.project_summary_path).to eq result
    end
  end

  describe "#show_browse_reserve_link" do
    it "should return true to display show browse link" do
      presenter = VisitsFormPresenter.new(user: build(:user))

      expect(presenter.show_browse_reserve_link).to eq true
    end
  end
end
