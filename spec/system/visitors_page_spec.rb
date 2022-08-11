require "rails_helper"

RSpec.describe "Schedule a visit - Add visitors page", type: :system, js: true do
  let(:user) { create(:user, :confirmed) }
  let(:visit) { create(:visit) }

  it "should display the visitors in the visitor list" do
    visitor1 = create(:user, :confirmed, first_name: "user1", last_name: "test1")
    user_visit1 = create(:user_visit, visit: visit, user: visitor1, role: "Other")

    sign_in(user)
    flow = AddVisitorsFlow.new(page)

    flow.visit_add_visitors_page(visit.id)

    expect(flow).to have_a_visitor(visitor1, user_visit1)
  end

  it "user should be able to delete a visitor from visitor list" do
    visitor1 = create(:user, :confirmed, first_name: "user1", last_name: "test1")
    user_visit1 = create(:user_visit, visit: visit, user: visitor1, role: "Other")

    sign_in(user)
    flow = AddVisitorsFlow.new(page)

    flow.visit_add_visitors_page(visit.id)

    expect(flow).to have_a_visitor(visitor1, user_visit1)
    flow.delete_user_visit(user_visit1)
    expect(flow).to be_not_showing_a_visitor(user_visit1)
  end

  it "should be able to change the add visitor form by clicking on action buttons" do
    sign_in(user)
    flow = AddVisitorsFlow.new(page)

    flow.visit_add_visitors_page(visit.id)

    expect(flow).to have_selected_add_team_member
    expect(flow).to have_section("#add-team-member")
    expect(flow).not_to have_section("#add-guest")
    expect(flow).not_to have_section("#add-group")

    flow.click_on_add_guest
    expect(flow).to have_section("#add-guest")
    expect(flow).not_to have_section("#add-team-member")
    expect(flow).not_to have_section("#add-group")

    flow.click_on_add_group
    expect(flow).to have_section("#add-group")
    expect(flow).not_to have_section("#add-team-member")
    expect(flow).not_to have_section("#add-guest")
  end

  it "should be able to change the arrival and departure date of a visitor" do
    visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
    user_visit = create(:user_visit, visit: visit, user: visitor, role: "Other")

    sign_in(user)
    flow = AddVisitorsFlow.new(page)

    flow.visit_add_visitors_page(visit.id)

    flow.click_on_change(user_visit)
    flow.change_user_visit_dates(arrives_at: user_visit.arrives_at + 1.day, departs_at: user_visit.departs_at)
    expect(flow).to have_visitor_dates(user_visit, "#{(user_visit.arrives_at + 1.day).strftime('%m/%d/%Y')} - #{user_visit.departs_at.strftime('%m/%d/%Y')}")
  end

  it "should return an error if the visitors date is out of the visit date range" do
    visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
    user_visit = create(:user_visit, visit: visit, user: visitor, role: "Other")

    sign_in(user)
    flow = AddVisitorsFlow.new(page)

    flow.visit_add_visitors_page(visit.id)

    flow.click_on_change(user_visit)
    flow.change_user_visit_dates(arrives_at: visit.start_date - 1.day, departs_at: visit.end_date)
    expect(flow).to have_error_message("must be after visit start date")
  end
end
