require "rails_helper"

RSpec.describe Visits::ReservesPresenter do
  describe "#reserves" do
    it "is the reserves where the project type matches the supplied type" do
      research_reserve = create(:reserve, research_projects_accepted: true)
      conference_reserve = create(:reserve, research_projects_accepted: false, conference_projects_accepted: true)
      presenter = Visits::ReservesPresenter.new(project_type: "research", reserve_id: nil)

      reserves = presenter.reserves

      expect(reserves.length).to eq 1
      expect(reserves.map(&:id)).to match_array [research_reserve.id]
    end

    it "orders the reserves alphabetically by pulldown_name" do
      reserve_c = create(:reserve, pulldown_name: "Reserve C", research_projects_accepted: true)
      reserve_a = create(:reserve, pulldown_name: "Reserve A", research_projects_accepted: true)
      reserve_b = create(:reserve, pulldown_name: "Reserve B", research_projects_accepted: true)
      presenter = Visits::ReservesPresenter.new(project_type: "research", reserve_id: nil)

      reserves = presenter.reserves

      expect(reserves.map(&:pulldown_name)).to eq ["Reserve A", "Reserve B", "Reserve C"]
    end
  end

  describe "#selected_reserve" do
    it "is 'selected' if the reserve_id matches the supplied reserve's id" do
      reserve = create(:reserve, research_projects_accepted: true)
      presenter = Visits::ReservesPresenter.new(
        project_type: "research",
        reserve_id: reserve.id.to_s,
      )

      expect(presenter.selected_reserve(reserve)).to eq "selected"
    end

    it "is nil if the reserve_id does not match the supplied reserve's id" do
      reserve = create(:reserve, research_projects_accepted: true)
      presenter = Visits::ReservesPresenter.new(
        project_type: "research",
        reserve_id: "5000000",
      )

      expect(presenter.selected_reserve(reserve)).to be_nil
    end
  end
end
