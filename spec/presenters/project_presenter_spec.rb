require "rails_helper"

RSpec.describe ProjectPresenter do
  describe "delegations" do
    subject { ProjectPresenter.new(project: create(:project)) }
    it { is_expected.to delegate_method(:id).to(:project) }
    it { is_expected.to delegate_method(:visits_count).to(:project) }
    it { is_expected.to delegate_method(:title).to(:project) }
    it { is_expected.to delegate_method(:applicant).to(:project) }
    it { is_expected.to delegate_method(:to_key).to(:project) }
    it { is_expected.to delegate_method(:model_name).to(:project) }
    it { is_expected.to delegate_missing_methods_to(:project) }
  end

  describe "#project_type" do
    it "capitalizes the first letter of the project type" do
      project_presenter = ProjectPresenter.new(
        project: create(:project, project_type: "research")
      )

      expect(project_presenter.project_type).to eq "Research"
    end

    it "converts underscores in the project type to spaces and capitalizes the first letter of each word" do
      project_presenter = ProjectPresenter.new(
        project: create(:project, project_type: "public_use")
      )

      expect(project_presenter.project_type).to eq "Public Use"
    end
  end

  describe "#timeframe" do
    context "when values for start_date and end_date are present" do
      it "has a timeframe" do
        start_date = Date.today
        end_date = Date.today + 1.day
        project_presenter = ProjectPresenter.new(
          project: create(:project, start_date: start_date, end_date: end_date)
        )
        allow(DateRangePresenter).to receive(:value)

        project_presenter.timeframe

        expect(DateRangePresenter).to have_received(:value)
          .with(start_date: start_date, end_date: end_date)
      end
    end

    context "when values for start_date and end_date are not present" do
      it "is 'N/A'" do
        project_presenter = ProjectPresenter.new(
          project: build(:project, start_date: nil, end_date: nil)
        )
        allow(DateRangePresenter).to receive(:value)

        result = project_presenter.timeframe

        expect(result).to eq "N/A"
        expect(DateRangePresenter).not_to have_received(:value)
      end
    end
  end

  describe "#recent_visit_date" do
    context "when the project has visits" do
      it "is the correctly formatted start_date of the most recent visit" do
        project = create(:project)
        create(:visit, project: project, start_date: Date.new(2019, 10, 1))
        create(:visit, project: project, start_date: Date.new(2021, 10, 1))
        project_presenter = ProjectPresenter.new(project: project)

        expect(project_presenter.recent_visit_date).to eq "Oct 01, 2021"
      end
    end

    context "when the project does not have visits" do
      it "is N/A" do
        project_presenter = ProjectPresenter.new(project: create(:project))

        expect(project_presenter.recent_visit_date).to eq "N/A"
      end
    end
  end

  describe "#recent_visit_reserve" do
    context "when the project has visits and the most recent visit has a reserve" do
      it "is is the reserve's short_name" do
        project = create(:project)
        reserve = create(:reserve, short_name: "Foo Reserve")
        create(:visit, project: project, reserve: reserve)
        project_presenter = ProjectPresenter.new(project: project)

        expect(project_presenter.recent_visit_reserve).to eq "Foo Reserve"
      end
    end

    context "when the project does not have visits" do
      it "is N/A" do
        project_presenter = ProjectPresenter.new(project: create(:project))

        expect(project_presenter.recent_visit_reserve).to eq "N/A"
      end
    end
  end

  describe "#applicant_name" do
    it "returns the project applicant full name" do
      user = create(:user, first_name: "Scrooge", last_name: "McDuck")
      project  = create(:project, applicant: user)

      project_presenter = ProjectPresenter.new(project: project)

      expect(project_presenter.applicant_name).to eq "Scrooge McDuck"
    end
  end

  describe "#owner_name" do
    it "returns the project owner full name" do
      user = create(:user, first_name: "Scrooge", last_name: "McDuck")
      project  = create(:project, owner: user)

      project_presenter = ProjectPresenter.new(project: project)

      expect(project_presenter.owner_name).to eq "Scrooge McDuck"
    end
  end
end
