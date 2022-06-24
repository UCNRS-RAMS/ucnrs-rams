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

  describe "#show_options" do
    it "is an array of show options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      show_options = presenter.show_options

      expect(show_options.to_a).to match_array [
        [I18n.t("manager.projects.index.all"), :all]
      ]
    end
  end

  describe "#sort_by_options" do
    it "is an array of sort by options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      sort_by_options = presenter.sort_by_options

      expect(sort_by_options.to_a).to match_array [
        [I18n.t("manager.projects.index.date_submitted"), :date_submitted],
        [I18n.t("manager.projects.index.project_title"), :project_title],
        [I18n.t("manager.projects.index.owner_last_name"), :owner_last_name],
      ]
    end
  end

  describe "#project_type_options" do
    it "is an array of project type options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      project_type_options = presenter.project_type_options

      expect(project_type_options.to_a).to match_array [
        ["Research", "research"],
        ["Class", "class"],
        ["Meeting", "meeting"],
        ["Public Use", "public_use"],
        ["Housing", "housing"],
      ]
    end
  end

  describe "#show_date_range_options" do
    it "is an array of show date range options" do
      reserve = create(:reserve)
      presenter = Manager::ProjectsIndexPresenter.new(reserve: reserve, page: 1)

      show_date_range_options = presenter.show_date_range_options

      expect(show_date_range_options.to_a).to match_array [
        [I18n.t("manager.projects.index.date_project_submitted"), :date_project_submitted],
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

      expect(reserve_options.to_a).to match_array Reserve.find_each.map { |r| [r.name, r.id] }
    end
  end
end
