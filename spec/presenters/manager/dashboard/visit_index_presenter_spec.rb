require "rails_helper"

RSpec.describe Manager::Dashboard::VisitsIndexPresenter do
  describe "#visits" do
    it "presents the visit records wrapped in VisitPresenter" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve)
      visit2 = create(:visit, reserve: reserve)

      presenter = Manager::Dashboard::VisitsIndexPresenter.new(reserve: reserve)

      expect(presenter.visits.map(&:id)).to match_array [visit1.id, visit2.id]
      expect(presenter.visits).to all(be_a(VisitPresenter))
    end
  end

  describe "#visit_scope" do
    it "only returns visits on the given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      visit1 = create(:visit, reserve: reserve1)
      visit2 = create(:visit, reserve: reserve1)
      visit3 = create(:visit, reserve: reserve2)
      presenter = Manager::Dashboard::VisitsIndexPresenter.new(reserve: reserve1, page: 1)

      scope = presenter.visit_scope

      expect(scope).to match_array [visit1, visit2]
    end

    it "returns a maximum of 10 projects" do
      reserve = create(:reserve)
      create_list(:visit, 11, reserve: reserve)
      presenter = Manager::Dashboard::VisitsIndexPresenter.new(reserve: reserve, page: 1)

      scope = presenter.visit_scope

      expect(scope.length).to eq 10
    end
  end

  describe "#visit_status_options" do
    it "is an array of visit status options" do
      allow(Visit).to receive(:statuses).and_return(
        {
          "status_1_key" => "status_1",
          "status_2_key" => "status_2",
        }
      )
      allow(I18n).to receive(:t)
        .and_call_original
      allow(I18n).to receive(:t)
        .with("universal.visit.statuses.status_1_key")
        .and_return("status_1_key_translate")
      allow(I18n).to receive(:t)
        .with("universal.visit.statuses.status_2_key")
        .and_return("status_2_key_translate")
      presenter = Manager::Dashboard::VisitsIndexPresenter.new()

      visit_status_options = presenter.visit_status_options

      expect(visit_status_options.to_a).to match_array [
        [I18n.t("all"), nil],
        ["status_1_key_translate", "status_1_key"],
        ["status_2_key_translate", "status_2_key"],
      ]
    end
  end

  describe "#visit_project_type_options" do
    it "is an array of project type options" do
      allow(Project).to receive(:project_types).and_return(
        {
          "project_type_1_key" => "project_type_1",
          "project_type_2_key" => "project_type_2",
        }
      )
      allow(I18n).to receive(:t)
        .and_call_original
      allow(I18n).to receive(:t)
        .with("universal.project.project_types.project_type_1_key")
        .and_return("project_type_1_key_translate")
      allow(I18n).to receive(:t)
        .with("universal.project.project_types.project_type_2_key")
        .and_return("project_type_2_key_translate")
      presenter = Manager::Dashboard::VisitsIndexPresenter.new()

      visit_project_type_options = presenter.visit_project_type_options

      expect(visit_project_type_options.to_a).to match_array [
        [I18n.t("all"), nil],
        ["project_type_1_key_translate", "project_type_1_key"],
        ["project_type_2_key_translate", "project_type_2_key"],
      ]
    end
  end

  describe "#sort_by_options" do
    it "is an array of sort by options" do
      reserve = create(:reserve)
      presenter = Manager::Dashboard::VisitsIndexPresenter.new(reserve: reserve)

      sort_by_options = presenter.sort_by_options

      expect(sort_by_options.to_a).to match_array [
        [I18n.t("manager.dashboard.visits.index.date_submitted"), :submitted_recent_first],
        [I18n.t("manager.dashboard.visits.index.visit_start_date"), :recent_start_date_first],
      ]
    end
  end

  describe "#reserve_options" do
    it "is an array of reserve options" do
      reserve = create(:reserve)
      presenter = Manager::Dashboard::VisitsIndexPresenter.new(reserve: reserve)

      reserve_options = presenter.reserve_options

      expect(reserve_options.to_a).to match_array Reserve.find_each.map { |r| [r.name, r.id] }.prepend(["All", nil])
    end
  end

  describe "#report_access_options" do
    it "is an array of report access options" do
      reserve = create(:reserve)
      presenter = Manager::Dashboard::VisitsIndexPresenter.new(reserve: reserve)

      report_access_options = presenter.report_access_options

      expect(report_access_options.to_a).to match_array [
        [I18n.t("all"), nil],
        [I18n.t("enabled"), true],
        [I18n.t("disabled"), false],
      ]
    end
  end

  describe "#amenity_options" do
    context "when reserve_filter is a number" do
      it "is an array of the reserve amenities with reserve id of the reserve_filter" do
        reserve = create(:reserve)
        amenity1 = create(:amenity, reserve: reserve)
        amenity2 = create(:amenity, reserve: reserve)
        presenter = Manager::Dashboard::VisitsIndexPresenter.new(reserve: reserve)

        amenity_options = presenter.amenity_options

        expect(amenity_options.to_a).to match_array [
          [I18n.t("all"), "all"],
          [amenity1.title, amenity1.id],
          [amenity2.title, amenity2.id],
        ]
      end
    end

    context "when reserve_filter is not present or not a number" do
      it "is a single array of ['all', 'all'] " do
        amenity1 = create(:amenity)
        amenity2 = create(:amenity)
        presenter = Manager::Dashboard::VisitsIndexPresenter.new(reserve: nil)

        amenity_options = presenter.amenity_options

        expect(amenity_options.to_a).to match_array [[I18n.t("all"), "all"]]
      end
    end
  end

  describe "delegations" do
    subject { Manager::Dashboard::VisitsIndexPresenter.new() }
    it { is_expected.to delegate_method(:visit_search_filter).to(:filter) }
    it { is_expected.to delegate_method(:sort_by_filter).to(:filter) }
    it { is_expected.to delegate_method(:reserve_filter).to(:filter) }
    it { is_expected.to delegate_method(:amenity_filter).to(:filter) }
    it { is_expected.to delegate_method(:date_range_type_filter).to(:filter) }
    it { is_expected.to delegate_method(:visit_project_type_filter).to(:filter) }
    it { is_expected.to delegate_method(:date_begin_filter).to(:filter) }
    it { is_expected.to delegate_method(:date_end_filter).to(:filter) }
    it { is_expected.to delegate_method(:visit_status_filter).to(:filter) }
    it { is_expected.to delegate_method(:report_access_filter).to(:filter) }
    it { is_expected.to delegate_method(:present?).to(:filter).with_prefix(true) }
  end
end
