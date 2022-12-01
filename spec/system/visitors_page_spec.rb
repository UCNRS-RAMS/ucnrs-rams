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
    institution = create(:institution, id: 2368)
    user = create(:user, :confirmed, institution: institution)
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
    date_range = DateRangePresenter.value(start_date: user_visit.arrives_at + 1.day, end_date: user_visit.departs_at)

    expect(flow).to have_visitor_dates(user_visit, "#{date_range}")
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

  describe "when on add a team member form" do
    it "adds the team member to the visitors list when 'Add To Visitor List' is clicked" do
      user = create(:user, :confirmed, first_name: "user1", last_name: "test1")
      create(:project_team_membership, user: user, project: visit.project)

      sign_in(user)
      flow = AddVisitorsFlow.new(page)

      flow.visit_add_visitors_page(visit.id)
      page.click_on("Add To Visitor List")

      expect(page).to have_css(".user-visit")
    end
  end

  describe "when on add group form" do
    it "adds the group record to the visitors list when 'Add Group' is clicked" do
      guest_user = create(:user, id: 1)
      institution = create(:institution, id: 2368)
      user = create(:user, :confirmed, institution: institution)

      sign_in(user)
      flow = AddVisitorsFlow.new(page)

      flow.visit_add_visitors_page(visit.id)
      page.click_on("Add Group")
      page.find("#user_visit_role").select("Faculty")
      page.find("#user_visit_count").set("4")
      click_button("Add Group")

      expect(page).to have_css(".user-visit")
    end
  end

  describe "when on add guest form" do
    it "shows suggestions when user name is typed" do
      user = create(:user, :confirmed)

      sign_in(user)
      flow = AddVisitorsFlow.new(page)
      flow.visit_add_visitors_page(visit.id)
      page.click_on("Add Guest")

      expect(page).to_not have_css(".list-group-item")

      page.find("#user_visit_guest_name").set("John")

      expect(page).to have_css(".list-group-item")
    end

    it "adds user to the visitors list when a user is selected from the suggestions list" do
      user = create(:user, :confirmed)

      sign_in(user)
      flow = AddVisitorsFlow.new(page)
      flow.visit_add_visitors_page(visit.id)

      page.click_on("Add Guest")
      page.find("#user_visit_guest_name").set("John Muir")
      page.find("#-option-0").click

      click_button("Add Visitor")

      expect(page).to have_css(".user-visit")
    end

    it "show modal to add new guest when no user is selected from the suggestions list" do
      guest_user = create(:user, id: 1)
      institution = create(:institution, id: 2368)
      user = create(:user, :confirmed, institution: institution)

      sign_in(user)
      flow = AddVisitorsFlow.new(page)
      flow.visit_add_visitors_page(visit.id)
      page.click_on("Add Guest")

      click_button("Add Visitor")

      page.has_css?("#modal")
      page.find("#modal #user_visit_guest_name").set("hafiz")
      page.find("#user_visit_role").select("Faculty")

      page.click_button("Save")

      expect(page).to have_css(".user-visit")
    end
  end

  describe "when click on new_institution link of edit user_visit modal" do
    it "previous form will swap with another form to create institute" do
      visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
      user_visit = create(:user_visit, visit: visit, user: visitor, role: "Other")

      sign_in(user)
      flow = AddVisitorsFlow.new(page)

      flow.visit_add_visitors_page(visit.id)

      flow.click_on_change(user_visit)
      flow.click_on_new_institution_link

      expect(page).to have_css("#institution-fields")
    end

    context "if instituion name field is dublicate" do
      it "display error" do
        visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
        institution = create(:institution, name: "university-abc", city: "houstan")
        user_visit = create(:user_visit, visit: visit, user: visitor, institution: institution, role: "Other")

        sign_in(user)
        flow = AddVisitorsFlow.new(page)

        flow.visit_add_visitors_page(visit.id)

        flow.click_on_change(user_visit)
        flow.click_on_new_institution_link

        flow.fill_form_for_institution

        flow.click_on_save_btn

        expect(page).to have_css(".error_messages")
      end
    end

    context "previous form will swap with another form" do
      it "it will create new institution and associate it with user_visit" do
        visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
        institution = create(:institution, name: "university-xyz")
        user_visit = create(:user_visit, visit: visit, user: visitor, institution: institution, role: "Other")

        sign_in(user)
        flow = AddVisitorsFlow.new(page)

        flow.visit_add_visitors_page(visit.id)

        flow.click_on_change(user_visit)
        flow.click_on_new_institution_link
        flow.fill_form_for_institution

        flow.click_on_save_btn

        expect(page).to have_css("td", text: "university-abc")
      end
    end
  end
end
