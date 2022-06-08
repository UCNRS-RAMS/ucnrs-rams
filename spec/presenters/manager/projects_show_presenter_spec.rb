require "rails_helper"

RSpec.describe Manager::ProjectShowPresenter do
  describe "#created_at" do
    it "display a formatted creation datetime of the project" do
      travel_to Time.zone.local(2004, 11, 24)
      project = create(:project, created_at: Time.current)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.created_at).to eq "Nov. 24, 2004"
    end
  end

  describe "#updated_at" do
    it "display a formatted updation datetime of the project" do
      travel_to Time.zone.local(2004, 11, 24)
      project = create(:project, updated_at: Time.current)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.updated_at).to eq "Nov. 24, 2004"
    end
  end

  describe "#owner_name" do
    it "display the full name of the project owner" do
      user1 = create(:user, first_name: "user", last_name: "one")
      project = create(:project, owner: user1)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.owner_name).to eq "user one"
    end
  end

  describe "#type" do
    it "display the type of the project" do
      project = create(:project, project_type: "public_use")
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.type).to eq "Public Use"
    end
  end

  describe "#reserve_names" do
    it "display the reserves name of visits for project" do
      project = create(:project)
      reserve1 = create(:reserve, name: "Test Reserve 1")
      reserve2 = create(:reserve, name: "Test Reserve 2")
      create(:visit, project: project, reserve: reserve1)
      create(:visit, project: project, reserve: reserve2)
      presenter = Manager::ProjectShowPresenter.new(project)

      expect(presenter.reserve_names).to eq "Test Reserve 1, Test Reserve 2"
    end
  end

  describe "#visits" do
    it "returns an array of Visits presenters" do
      project = create(:project)
      visits = create_list(:visit, 3, project: project)
      presenter = Manager::ProjectShowPresenter.new(project)

      expected_array_ids = visits.pluck(:id)

      expect(presenter.visits.map(&:id)).to eq expected_array_ids
    end
  end
end
