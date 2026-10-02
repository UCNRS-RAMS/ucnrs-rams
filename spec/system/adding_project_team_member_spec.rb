require "rails_helper"

RSpec.describe "Adding a project team member", type: :system, js: true do
  commits_data_for_full_text_search!(additional_tables: %w[project_team_memberships projects reserves users])

  it "creates a user with a selected ROR institution" do
    country = create(:country, code: "US", name: "United States")
    state = create(:state, name: "California", country: country)
    ror = create(
      :ror,
      name: "ROR Test University",
      country: { "country_code" => country.code },
      locations: [ { "geonames_details" => { "name" => "Berkeley" } } ],
    )
    user = create(:user, :confirmed, address_country: country, address_state: state)
    project = create(:project, owner: user, applicant: user)
    create(:project_team_membership, :principal_investigator, project: project, user: user, institution: user.institution)
    sign_in(user)

    visit project_team_memberships_path(project)
    click_link "Create new user"
    fill_in "Last name", with: "Member"
    fill_in "Email", with: "new.member@example.test"
    fill_in "Phone number", with: "111-111-1111"
    fill_in "Emergency contact full name", with: "Emergency Contact"
    fill_in "Emergency contact phone number", with: "222-222-2222"
    fill_in "Institution name", with: ror.name
    find(".autocomplete-results li", text: ror.name).click
    select "Other", from: "User role"
    select "Team Member", from: "Project role"
    find("#user_address_country_id option[value='#{country.id}']").select_option
    fill_in "Address line 1", with: "123 Main Street"
    fill_in "Address city", with: "Berkeley"
    fill_in "Address postal code", with: "94704"
    select state.name, from: "Address state"

    click_button "Save"
    expect(page).to have_css(".modal.visible h2", text: "Create a New User")
    expect(page.find("#user_institution_selection_id", visible: false).value).to eq(ror.ror_id)
    expect(page.find("#user_institution_selection_type", visible: false).value).to eq("ror")
    fill_in "First name", with: "New"
    expect(page.find("#user_institution_selection_id", visible: false).value).to eq(ror.ror_id)
    expect(page.find("#user_institution_selection_type", visible: false).value).to eq("ror")
    click_button "Save"
    expect(page).to have_no_css(".modal.visible")

    new_user = User.find_by!(email: "new.member@example.test")
    expect(new_user.institution).to have_attributes(
      name: ror.name,
      ror_id: ror.ror_id,
    )
    expect(new_user.project_team_memberships.find_by!(project: project)).to be_persisted
  end
end
