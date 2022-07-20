require "rails_helper"

RSpec.describe Manager::ReserveInfo::StaffAndNotificationsIndexPresenter do
  describe ".personnel" do
    it "returns results in ReservePermitPresenter" do
      reserve = create :reserve
      reserve_personnel1 = create(:reserve_personnel, reserve: reserve)
      reserve_personnel2 = create(:reserve_personnel, reserve: reserve)
      presenter = Manager::ReserveInfo::StaffAndNotificationsIndexPresenter.new(reserve: reserve)

      results = presenter.personnel

      expect(results).to all(be_a(PersonnelPresenter))
    end
  end

  describe ".personnel_scope" do
    it "returns personnel for the given reserve" do
      reserve = create :reserve
      reserve_personnel1 = create(:reserve_personnel, reserve: reserve)
      reserve_personnel2 = create(:reserve_personnel)
      reserve_personnel3 = create(:reserve_personnel, reserve: reserve)
      presenter = Manager::ReserveInfo::StaffAndNotificationsIndexPresenter.new(reserve: reserve)

      scope = presenter.personnel_scope

      expect(scope).to match_array [reserve_personnel1, reserve_personnel3]
    end
  end
end
