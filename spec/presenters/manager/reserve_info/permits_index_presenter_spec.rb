require "rails_helper"

RSpec.describe Manager::ReserveInfo::PermitsIndexPresenter do
  describe ".reserve_permits" do
    it "returns results in ReservePermitPresenter" do
      reserve = create :reserve
      reserve_permit1 =  create :reserve_permit, reserve: reserve
      reserve_permit2 =  create :reserve_permit, reserve: reserve
      presenter = Manager::ReserveInfo::PermitsIndexPresenter.new(reserve: reserve)
  
      results = presenter.reserve_permits
      
      expect(results.values.flatten).to all(be_a(ReservePermitPresenter))
    end

    it "groups reserve_permits according to 'permits.authority'" do
      reserve = create :reserve
      reserve_permit1 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Federal")
      reserve_permit2 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Institution")
      reserve_permit3 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Federal")
      reserve_permit4 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Institution")
      presenter = Manager::ReserveInfo::PermitsIndexPresenter.new(reserve: reserve)
  
      results = presenter.reserve_permits
      
      expect(results.keys).to match_array ["Federal", "Institution"]
      expect(results["Federal"].map(&:id)).to match_array [reserve_permit1.id, reserve_permit3.id]
      expect(results["Institution"].map(&:id)).to match_array [reserve_permit2.id, reserve_permit4.id]
    end
  end

  describe ".reserve_permits_scope" do
    it "returns reserve_permits for the given reserve" do
      reserve = create :reserve
      reserve_permit1 =  create :reserve_permit, reserve: reserve
      reserve_permit2 =  create :reserve_permit
      reserve_permit3 =  create :reserve_permit, reserve: reserve
      presenter = Manager::ReserveInfo::PermitsIndexPresenter.new(reserve: reserve)
      
      scope = presenter.reserve_permits_scope

      expect(scope).to match_array [reserve_permit1, reserve_permit3]
    end

    it "returns reserve_permits with 'permit_authority' column" do
      reserve = create :reserve
      reserve_permit1 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Federal")
      reserve_permit2 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Institution")
      presenter = Manager::ReserveInfo::PermitsIndexPresenter.new(reserve: reserve)

      scope = presenter.reserve_permits_scope

      expect(scope.map(&:permit_authority)).to match_array ["Federal", "Institution"]
    end

    it "returns reserve_permits in order of enum 'permit.authority' [Federal, State, Local, Institution]" do
      reserve = create :reserve
      reserve_permit1 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Institution")
      reserve_permit2 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Federal")
      reserve_permit3 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "Local")
      reserve_permit4 =  create :reserve_permit, reserve: reserve, permit: create(:permit, authority: "State")
      presenter = Manager::ReserveInfo::PermitsIndexPresenter.new(reserve: reserve)

      scope = presenter.reserve_permits_scope

      expect(scope).to eq [reserve_permit2, reserve_permit4, reserve_permit3, reserve_permit1]
    end

    it "returns reserve_permits in order of column 'sort_order_override'" do
      reserve = create :reserve
      reserve_permit1 =  create :reserve_permit, reserve: reserve, sort_order_override: 4
      reserve_permit2 =  create :reserve_permit, reserve: reserve, sort_order_override: 2
      reserve_permit3 =  create :reserve_permit, reserve: reserve, sort_order_override: 3
      reserve_permit4 =  create :reserve_permit, reserve: reserve, sort_order_override: 1
      presenter = Manager::ReserveInfo::PermitsIndexPresenter.new(reserve: reserve)

      scope = presenter.reserve_permits_scope

      expect(scope).to eq [reserve_permit4, reserve_permit2, reserve_permit3, reserve_permit1]
    end
  end
end
