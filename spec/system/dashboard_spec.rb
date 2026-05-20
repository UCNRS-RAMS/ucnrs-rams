require "rails_helper"

RSpec.describe "Dashboard", type: :system, js: true do
  it "is WCAG compliant" do
    user = create(:user, :confirmed)
    sign_in(user)

    flow = DashboardFlow.new(page)
    flow.visit_dashboard

    expect(page).to be_axe_clean
  end
end
