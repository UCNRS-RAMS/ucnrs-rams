require "rails_helper"

RSpec.describe ProjectReserveInterest, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reserve) }
  end

  describe "validations" do
    it "allows a reserve only once per project" do
      interest = create(:project_reserve_interest)
      duplicate = build(:project_reserve_interest, project: interest.project, reserve: interest.reserve)

      expect(duplicate).not_to be_valid
    end
  end

  describe ".without_submitted_visit" do
    it "excludes interests whose project has a submitted visit at that reserve" do
      reserve = create(:reserve)
      interest = create(:project_reserve_interest, reserve: reserve)
      create(:visit, project: interest.project, reserve: reserve, status: :in_review)

      expect(ProjectReserveInterest.without_submitted_visit).to be_empty
    end

    it "keeps interests when the submitted visit is at a different reserve" do
      interest = create(:project_reserve_interest)
      create(:visit, project: interest.project, reserve: create(:reserve), status: :approved)

      expect(ProjectReserveInterest.without_submitted_visit).to contain_exactly(interest)
    end

    it "keeps interests when the only visit at that reserve is a draft" do
      reserve = create(:reserve)
      interest = create(:project_reserve_interest, reserve: reserve)
      create(:visit, project: interest.project, reserve: reserve, status: :incomplete)

      expect(ProjectReserveInterest.without_submitted_visit).to contain_exactly(interest)
    end

    it "excludes interests once a visit at that reserve is denied or cancelled" do
      reserve = create(:reserve)
      denied = create(:project_reserve_interest, reserve: reserve)
      cancelled = create(:project_reserve_interest, reserve: reserve)
      create(:visit, project: denied.project, reserve: reserve, status: :denied)
      create(:visit, project: cancelled.project, reserve: reserve, status: :cancelled)

      expect(ProjectReserveInterest.without_submitted_visit).to be_empty
    end
  end
end
