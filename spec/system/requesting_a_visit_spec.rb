require "rails_helper"

RSpec.describe "Requesting a Visit", type: :system, js: true do
  it "re-calculates the subtotal on changing the fields in date range" do
    user = create(:user, :confirmed)
    reserve = create(:reserve, name: "Silver Lake Area")
    project = create(
      :project,
      title: "Fun",
      project_type: "class",
      reserve: reserve,
      members: [user]
    )
    amenity = create(:amenity, reserve: reserve, title: "title 1")
    amenity_rate_category = create(:amenity_rate_category, reserve: reserve, state_university: true)
    amenity.amenity_rates.first.update(rate: 10)

    sign_in(user)

    flow = RequestVisitFlow.new(page)
    flow.visit_new_visit_page
    flow.select_project("Class - Fun")
    flow.select_reserve("Silver Lake Area")
    find("header", text: "Label 1").click
    flow.select_amenity("title 1")

    flow.inside_amenity(amenity) do
      flow.increment_count
      expect(flow).to have_subtotal("20.00")
      flow.decrement_count
      expect(flow).to have_subtotal("10.00")
    end
  end
end
