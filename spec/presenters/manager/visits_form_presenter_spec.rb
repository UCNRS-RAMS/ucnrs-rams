require "rails_helper"

RSpec.describe Manager::VisitsFormPresenter do
  describe "#projects" do
    it "initializes a Manager::Visits::ProjectsPresenter" do
      presenter = Manager::VisitsFormPresenter.new(user: build(:user))

      visit_projects_presenter = presenter.projects

      expect(visit_projects_presenter.projects).to eq [Project.blank]
      expect(visit_projects_presenter.project_id).to be_nil
      expect(visit_projects_presenter.project_type).to be_nil
    end
  end

  describe "#project_partial_path" do
    it "should return 'shared/visits/project' when editing" do
      form = VisitForm.new(params: { reserve_id: create(:reserve).id }, editing: true)
      presenter = Manager::VisitsFormPresenter.new(user: build(:user), form: form)

      expect(presenter.project_partial_path).to eq "shared/visits/project"
    end

    it "should return 'manager/visits/project' when not editing" do
      form = VisitForm.new(params: { reserve_id: create(:reserve).id }, editing: false)
      presenter = Manager::VisitsFormPresenter.new(user: build(:user), form: form)

      expect(presenter.project_partial_path).to eq "manager/visits/project"
    end
  end
end
