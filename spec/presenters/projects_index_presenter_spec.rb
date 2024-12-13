require "rails_helper"

RSpec.describe ProjectsIndexPresenter do
  describe "#projects" do
    context "when a recognized status filter is supplied" do
      it "presents the project records" do
        user = create(:user)
        project_team_membership1 = create(:project_team_membership, user: user, active: true)
        project_team_membership2 = create(:project_team_membership, user: user, active: true)
        first_project = project_team_membership1.project
        second_project = project_team_membership2.project
        presenter = ProjectsIndexPresenter.new(
          user: user,
          page: 1,
          status_filter: "All Projects",
        )

        expect(presenter.projects.map(&:id)).to match_array [
          first_project.id,
          second_project.id,
        ]
      end
    end

    context "when an unrecognized status filter is supplied" do
      it "is an empty array" do
        user = create(:user)
        project_team_membership1 = create(:project_team_membership, user: user, active: true)
        project_team_membership2 = create(:project_team_membership, user: user, active: true)
        first_project = project_team_membership1.project
        second_project = project_team_membership2.project
        presenter = ProjectsIndexPresenter.new(
          user: user,
          page: 1,
          status_filter: "Foo",
        )

        expect(presenter.projects).to be_empty
      end
    end
  end

  describe "#project_scope" do
    it "only returns projects where the user is an active team member" do
      user = create(:user)
      first_active_project = create(:project)
      second_active_project = create(:project)
      inactive_project = create(:project)
      create(:project_team_membership, user: user, project: first_active_project, active: true)
      create(:project_team_membership, user: user, project: second_active_project, active: true)
      create(:project_team_membership, user: user, project: inactive_project, active: false)
      presenter = ProjectsIndexPresenter.new(user: user, page: 1, status_filter: "All Projects")

      scope = presenter.project_scope

      expect(scope.length).to eq 2
      expect(scope.map(&:id)).to match_array [
        first_active_project.id,
        second_active_project.id,
      ]
    end

    it "returns the projects where the user is an active team member in the correct order" do
      user = create(:user)
      project_with_no_visit = create(:project)
      project_with_future_visit = create(:project)
      project_with_current_visit = create(:project)
      project_with_past_visit = create(:project)
      create(:project_team_membership, project: project_with_no_visit, user: user)
      create(:project_team_membership, project: project_with_future_visit, user: user)
      create(:project_team_membership, project: project_with_current_visit, user: user)
      create(:project_team_membership, project: project_with_past_visit, user: user)
      future_visit = create(
        :visit,
        project: project_with_future_visit,
        starts_at: Time.current + 1.year,
        ends_at: Time.current + 2.years,
        submitted_at: Time.current,
      )
      current_visit = create(
        :visit,
        project: project_with_current_visit,
        starts_at: Time.current - 1.year,
        ends_at: Time.current + 2.months,
        submitted_at: Time.current,
      )
      past_visit = create(
        :visit,
        project: project_with_past_visit,
        starts_at: Time.current - 1.year,
        ends_at: Time.current - 6.months,
        submitted_at: Time.current,
      )
      presenter = ProjectsIndexPresenter.new(user: user, page: 1, status_filter: "All Projects")

      scope = presenter.project_scope

      expect(scope.map(&:id)).to eq [
        project_with_future_visit.id,
        project_with_current_visit.id,
        project_with_past_visit.id,
        project_with_no_visit.id,
      ]
    end

    it "returns the correct projects based on the supplied status" do
      user = create(:user)
      first_open_project = create(:project, status: :open)
      second_open_project = create(:project, status: :open)
      closed_project = create(:project, status: :closed)
      create(:project_team_membership, project: first_open_project, user: user, active: true)
      create(:project_team_membership, project: second_open_project, user: user, active: true)
      create(:project_team_membership, project: closed_project, user: user, active: true)
      presenter = ProjectsIndexPresenter.new(
        user: user,
        page: 1,
        status_filter: "Active Projects",
      )

      scope = presenter.project_scope

      expect(scope.map(&:id)).to match_array [
        first_open_project.id,
        second_open_project.id,
      ]
    end

    it "returns a maxiumum of 10 projects" do
      user = create(:user)
      presenter = ProjectsIndexPresenter.new(user: user, page: 1, status_filter: "All Projects")
      create_list(:project_team_membership, 11, user: user)

      scope = presenter.project_scope

      expect(scope.length).to eq 10
    end
  end

  describe "#selected?" do
    it "is 'selected' if the supplied option is the same as the status_filter" do
      user = create(:user)
      presenter = ProjectsIndexPresenter.new(user: user, page: 1, status_filter: "All Projects")

      expect(presenter.selected?("All Projects")).to eq("selected")
    end

    it "is an empty string if the supplied option is different than the status_filter" do
      user = create(:user)
      presenter = ProjectsIndexPresenter.new(user: user, page: 1, status_filter: "Incomplete Projects")

      expect(presenter.selected?("All Projects")).to be_blank
    end
  end

  describe "#filter_options" do
    it "returns the keys of the Project::STATUS_FILTERS constant" do
      user = create(:user)
      presenter = ProjectsIndexPresenter.new(user: user, page: 1, status_filter: "All Projects")

      expect(presenter.filter_options).to eq Project::STATUS_FILTERS.keys
    end
  end
end
