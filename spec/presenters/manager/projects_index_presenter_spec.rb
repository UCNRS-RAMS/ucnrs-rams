require "rails_helper"

RSpec.describe Manager::ProjectsIndexPresenter do
  describe "#projects" do
    it "presents the project records" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve)
      visit2 = create(:visit, reserve: reserve)
      project1 = create(:project, visits: [visit1])
      project2 = create(:project, visits: [visit2])
      
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      expect(presenter.projects.map(&:id)).to match_array [project1.id, project2.id]
    end
  end

  describe "#project_scope" do
    it "only returns projects that have visits on the given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      visit1 = create(:visit, reserve: reserve1)
      visit2 = create(:visit, reserve: reserve1)
      visit3 = create(:visit, reserve: reserve2)
      project1 = create(:project, visits: [visit1, visit3])
      project2 = create(:project, visits: [visit2])
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve1, page: 1)

      scope = presenter.project_scope

      expect(scope.map(&:id)).to match_array [project1.id, project2.id]
    end

    it "returns the projects ordered by the latest submitted_at date" do
      reserve = create(:reserve)
      visit1 = create(:visit, reserve: reserve)
      visit2 = create(:visit, reserve: reserve)
      visit3 = create(:visit, reserve: reserve)
      project_not_submitted = create(:project, visits: [visit1], submitted_at: nil)
      project_submitted_yesterday = create(:project, visits: [visit2], submitted_at: Time.current.yesterday)
      project_submitted_today = create(:project, visits: [visit3], submitted_at: Time.current)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      scope = presenter.project_scope

      expect(scope.map(&:id)).to eq [
        project_submitted_today.id,
        project_submitted_yesterday.id,
      ]
    end

    it "returns a maximum of 10 projects" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)
      create_list(:visit, 11, reserve: reserve)

      scope = presenter.project_scope

      expect(scope.length).to eq 10
    end
  end

  describe "#project_status_options" do
    it "is an array of project status options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      project_status_options = presenter.project_status_options

      expect(project_status_options.to_a).to match_array [
        ["All", Project::ALL_FILTER],
        ["Open", Project::ACTIVE_FILTER],
        ["Closed", Project::INACTIVE_FILTER],
        ["Incomplete", Project::INCOMPLETE_FILTER],
      ]
    end
  end

  describe "#sort_by_options" do
    it "is an array of sort by options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      sort_by_options = presenter.sort_by_options

      expect(sort_by_options.to_a).to match_array [
        [I18n.t("manager.projects.index.date_submitted"), :submitted_recent_first],
        [I18n.t("manager.projects.index.project_title"), :sort_by_project_title],
        [I18n.t("manager.projects.index.owner_last_name"), :sort_by_owner_last_name],
      ]
    end
  end

  describe "#project_type_options" do
    it "is an array of project type options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      project_type_options = presenter.project_type_options

      expect(project_type_options.to_a).to match_array [
        ["All", :all],
        ["Research", :research],
        ["University Class", :university_class],
        ["Meeting or Conference", :meeting_or_conference],
        ["Public Use", :public_use],
      ]
    end
  end

  describe "#show_date_range_options" do
    it "is an array of show date range options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      show_date_range_options = presenter.show_date_range_options

      expect(show_date_range_options.to_a).to match_array [
        [I18n.t("manager.projects.index.date_project_submitted"), :project_submitted_date_range],
        [I18n.t("manager.projects.index.project_date_range"), :project_date_range],
        [I18n.t("manager.projects.index.visit_date_range"), :visit_date_range],
        [I18n.t("manager.projects.index.invoice_created_at_date_range"), :invoice_created_at_date_range],
      ]
    end
  end

  describe "#reserve_options" do
    it "is an array of reserve options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      reserve_options = presenter.reserve_options

      expect(reserve_options.to_a).to match_array Reserve.find_each.map { |r| [r.name, r.id] }.prepend(["All", nil])
    end
  end

  describe "#project_search_filter" do
    it "returns the filter[:project_search] if present" do
      reserve = create(:reserve)
      filter = { project_search: "search_this" }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      project_search_filter = presenter.project_search_filter

      expect(project_search_filter).to eq "search_this"
    end
  end

  describe "#sort_by_filter" do
    it "returns filter[:search] if present" do
      reserve = create(:reserve)
      filter = { sort_by: "sort_by_this" }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      sort_by_filter = presenter.sort_by_filter

      expect(sort_by_filter).to eq "sort_by_this"
    end

    it "returns the 'submitted_recent_first' if not present" do
      reserve = create(:reserve)
      filter = { sort_by: "" }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      sort_by_filter = presenter.sort_by_filter

      expect(sort_by_filter).to eq "submitted_recent_first"
    end
  end

  describe "#reserve_filter" do
    it "returns filter[:reserve] if present" do
      reserve = create(:reserve)
      filter = { reserve: 1 }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      reserve_filter = presenter.reserve_filter

      expect(reserve_filter).to eq 1
    end

    it "returns @reserve.id if nil" do
      reserve = create(:reserve)
      filter = { reserve: nil }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      reserve_filter = presenter.reserve_filter

      expect(reserve_filter).to eq reserve.id
    end
  end

  describe "#date_range_type_filter" do
    it "returns filter[:date_range_type]" do
      reserve = create(:reserve)
      filter = { date_range_type: "this range type" }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      date_range_type_filter = presenter.date_range_type_filter

      expect(date_range_type_filter).to eq "this range type"
    end
  end

  describe "#project_type_filter" do
    it "returns filter[:project_type] if present" do
      reserve = create(:reserve)
      filter = { project_type: "researching" }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      project_type = presenter.project_type_filter

      expect(project_type).to eq "researching"
    end

    it "returns 'all' if not present" do
      reserve = create(:reserve)
      filter = { project_type: "" }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      project_type = presenter.project_type_filter

      expect(project_type).to eq "all"
    end
  end

  describe "#date_begin_filter" do
    it "returns filter[:date_begin]" do
      reserve = create(:reserve)
      date1 = Date.new(1944, 6, 6)
      filter = { date_begin: date1 }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      date_begin = presenter.date_begin_filter

      expect(date_begin).to eq date1
    end
  end

  describe "#date_end_filter" do
    it "returns filter[:date_end]" do
      reserve = create(:reserve)
      date1 = Date.new(1944, 6, 6)
      filter = { date_end: date1 }
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, filter: filter)

      date_end = presenter.date_end_filter

      expect(date_end).to eq date1
    end
  end
end
