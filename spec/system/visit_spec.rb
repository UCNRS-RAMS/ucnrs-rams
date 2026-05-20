require "rails_helper"

RSpec.describe "Visit show page", type: :system, js: true do
  let(:user) { create(:user, :confirmed) }

  it "is WCAG compliant" do
    institution = create(:institution)
    reserve = create(:reserve, :with_full_address, :with_rules_and_directions)
    project = create(:project, reserve: reserve)
    create(:project_team_membership, project: project, user: user)
    visit_record = create(:visit, user: user, reserve: reserve, project: project, status: :approved)
    visitor = create(:user, :confirmed, institution: institution)
    create(:user_visit, visit: visit_record, user: visitor, institution: institution)
    create(:amenity_visit, visit: visit_record)
    create(:amenity_visit, visit: visit_record)
    create(:reserve_personnel, reserve: reserve)
    create(:reserve_personnel, reserve: reserve)
    create(:waiver, :with_full_info, reserves: [reserve])

    sign_in(user)

    flow = VisitShowFlow.new(page)
    flow.visit_show_page(visit_record.id)

    expect(page).to be_axe_clean
  end
end
