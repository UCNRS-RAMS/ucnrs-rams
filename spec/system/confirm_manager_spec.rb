require "rails_helper"

RSpec.describe "Confirm manager", type: :system, js: true do
  describe "when user is a personnel of a reserve" do
    it "allows the user to visit the manager pages" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)
      flow = ConfirmManagerFlow.new(page)

      flow.visit_manager_reserve_dashboard(reserve.id)
      expect(flow).to be_on_manager_reserve_dashboard
    end
  end

  describe "when user is NOT a personnel of the reserve" do
    it "means the user gets redirected to root home page when going to manager reserve page" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      sign_in(user)
      flow = ConfirmManagerFlow.new(page)

      flow.visit_manager_reserve_dashboard(reserve.id)
      expect(flow).to be_on_root_home_page
    end
  end
end
