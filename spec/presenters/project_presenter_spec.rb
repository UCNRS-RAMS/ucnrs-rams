require "rails_helper"

RSpec.describe ProjectPresenter do
  describe "delegations" do
    subject { ProjectPresenter.new(create(:project)) }
    it { is_expected.to delegate_method(:id).to(:project) }
    it { is_expected.to delegate_method(:project_type).to(:project) }
    it { is_expected.to delegate_method(:visits_count).to(:project) }
    it { is_expected.to delegate_method(:title).to(:project) }
  end

  describe "#timeframe" do
    context "when values for start_date and end_date are present" do
      it "has a timeframe" do
        start_date = Date.today
        end_date = Date.today + 1.day
        project_presenter = ProjectPresenter.new(
          create(:project, start_date: start_date, end_date: end_date)
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
          create(:project, start_date: nil, end_date: nil)
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
        project_presenter = ProjectPresenter.new(project)
  
        expect(project_presenter.recent_visit_date).to eq "Oct 01, 2021"
      end
    end

    context "when the project does not have visits" do
      it "is N/A" do
        project_presenter = ProjectPresenter.new(create(:project))

        expect(project_presenter.recent_visit_date).to eq "N/A"
      end
    end
  end
end
