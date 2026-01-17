require "rails_helper"

RSpec.describe Manager::Reports::ReportPart3::ProjectPresenter do
  describe "#timeframe" do
    it "returns not applicable when there is no user visits under the project" do
      user = create(:user)
      project = create(:project, owner: user)
      create(:visit, project: project)
      allow(I18n).to receive(:t)
        .with(".projects.project.not_applicable")
        .and_return("not_applicable_translate")
      presenter = Manager::Reports::ReportPart3::ProjectPresenter.new(
        project:, start_date: nil, stop_date: nil)

      timeframe = presenter.timeframe

      expect(timeframe).to eq "not_applicable_translate"
    end

    it "returns a timeframe when there is a user visit under the project" do
      user = create(:user)
      project = create(:project, owner: user)
      visit = create(:visit, project: project)
      user_visit = create(:user_visit,
        visit: visit, arrives_at: 2.days.ago, departs_at: 2.days.from_now)
      allow(DateRangePresenter).to receive(:value)
      presenter = Manager::Reports::ReportPart3::ProjectPresenter.new(
        project: project, start_date: 6.months.ago.to_date, stop_date: 6.months.from_now.to_date)

      presenter.timeframe

      expect(DateRangePresenter).to have_received(:value)
        .with(start_date: user_visit.arrives_at.to_date, end_date: user_visit.departs_at.to_date)
    end

    context "when there are more than one user visits" do
      it "returns a timeframe of the earliest arrival and latest departure" do
        user = create(:user)
        project = create(:project, owner: user)
        visit = create(:visit, project: project)
        user_visit1 = create(:user_visit,
          visit: visit, arrives_at: 5.days.ago, departs_at: 3.days.ago)
        user_visit2 = create(:user_visit,
          visit: visit, arrives_at: 2.days.ago, departs_at: 2.days.from_now)
        user_visit3 = create(:user_visit,
          visit: visit, arrives_at: 5.days.from_now, departs_at: 7.days.from_now)
        allow(DateRangePresenter).to receive(:value)
        presenter = Manager::Reports::ReportPart3::ProjectPresenter.new(
          project: project, start_date: 6.months.ago.to_date, stop_date: 6.months.from_now.to_date)

        presenter.timeframe

        expect(DateRangePresenter).to have_received(:value)
          .with(start_date: user_visit1.arrives_at.to_date, end_date: user_visit3.departs_at.to_date)
      end
    end

    context "when there the user visit arrival is earlier than report start date" do
      it "returns a the report start date" do
        user = create(:user)
        project = create(:project, owner: user)
        visit = create(:visit, project: project)
        user_visit1 = create(:user_visit,
          visit: visit, arrives_at: 5.days.ago, departs_at: 3.days.ago)
        user_visit2 = create(:user_visit,
          visit: visit, arrives_at: 7.months.ago, departs_at: 2.days.from_now)
        user_visit3 = create(:user_visit,
          visit: visit, arrives_at: 5.days.from_now, departs_at: 7.days.from_now)
        allow(DateRangePresenter).to receive(:value)
        presenter = Manager::Reports::ReportPart3::ProjectPresenter.new(
          project: project, start_date: 6.months.ago.to_date, stop_date: 6.months.from_now.to_date)

        presenter.timeframe

        expect(DateRangePresenter).to have_received(:value)
          .with(start_date: 6.months.ago.to_date, end_date: user_visit3.departs_at.to_date)
      end
    end

    context "when there the user visit departure is later than report stop date" do
      it "returns a the report stop date" do
        user = create(:user)
        project = create(:project, owner: user)
        visit = create(:visit, project: project)
        user_visit1 = create(:user_visit,
          visit: visit, arrives_at: 5.days.ago, departs_at: 3.days.ago)
        user_visit2 = create(:user_visit,
          visit: visit, arrives_at: 2.days.ago, departs_at: 7.months.from_now)
        user_visit3 = create(:user_visit,
          visit: visit, arrives_at: 5.days.from_now, departs_at: 7.days.from_now)
        allow(DateRangePresenter).to receive(:value)
        presenter = Manager::Reports::ReportPart3::ProjectPresenter.new(
          project: project, start_date: 6.months.ago.to_date, stop_date: 6.months.from_now.to_date)

        presenter.timeframe

        expect(DateRangePresenter).to have_received(:value)
          .with(start_date: user_visit1.arrives_at.to_date, end_date: 6.months.from_now.to_date)
      end
    end
  end
end
