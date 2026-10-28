require "rails_helper"

RSpec.describe "Creating a project", type: :system, js: true do
  it "can switch between forms per-project_type" do
    user = create(:user, :confirmed)
    sign_in(user)
    flow = CreateProjectFlow.new(page)

    flow.visit_new_project_page
    flow.dismiss_modal
    expect(flow).to have_no_selected_project_type("Research")
    expect(flow).to have_no_selected_project_type("Meeting")
    expect(flow).to have_no_selected_project_type("University Course")
    expect(flow).to have_no_selected_project_type("Public Use")

    flow.select_project_type("Research")
    expect(flow).to have_selected_project_type("Research")
    expect(flow).to be_showing_project_form("Research")

    flow.select_project_type("Meeting")
    expect(flow).to have_selected_project_type("Meeting")
    expect(flow).to be_showing_project_form("Meeting")
  end
end
