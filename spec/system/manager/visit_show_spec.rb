require "rails_helper"

RSpec.describe "Manager Visit Show" do
  let(:user) { create(:user, :confirmed) }
  let!(:reserve) { create(:reserve, name: "Test Reserve") }
  let!(:reserve_personnel) { create(:reserve_personnel, user: user, reserve: reserve) }
  let(:visit) { create(:visit, reserve: reserve) }

  describe "it displays project show page" do
    it "includes summary box and menu bar", js: true do
      sign_in(user)
      flow = VisitShowFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_showing_summary_box
      expect(flow).to be_showing_menu_bar
    end

    it "includes only summary box and do not have menu bar and status button", js: true do
      local_reserve = create(:reserve)
      local_visit = create(:visit, reserve: local_reserve)
      sign_in(user)
      flow = VisitShowFlow.new(page: page, visit_id: local_visit.id, reserve_id: local_reserve.id)

      flow.visit_show_page

      expect(flow).to be_showing_summary_box
      expect(flow).not_to be_showing_trash_and_status_btn
      expect(flow).not_to be_showing_menu_bar
    end

    it "render summary partial when click on status button", js: true do
      sign_in(user)
      flow = VisitShowFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_status_btn

      expect(flow).to be_showing_summary_partial
    end
  end

  describe "it delete visit and its associated records" do
    it "when click on trash icon", js: true do
      sign_in(user)
      flow = VisitShowFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page

      flow.click_on_trash_icon

      Visit.find_by(id: visit.id).nil?
    end
  end

  describe "when click on details button" do
    it "should not show radio button for project type", js: true do
      sign_in(user)
      flow = VisitShowFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page

      flow.click_on_details_btn

      expect(flow.showing_purpose_of_visit?).to eq false
    end

    it "should not show project_types and show project link", js: true do
      sign_in(user)
      flow = VisitShowFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page

      flow.click_on_details_btn

      expect(flow.showing_project_dropdown?).to eq false
      expect(flow.showing_project_link?).to eq true
    end
  end

  describe "when click on visitor tab" do
    it "should display the visitors in the visitor list", js: true do
      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab

      expect(flow.visitors_tab_content?).to eq true
    end

    it "should display the visitors in the visitor list" do
      visitor1 = create(:user, :confirmed, first_name: "user1", last_name: "test1")
      user_visit1 = create(:user_visit, visit: visit, user: visitor1, role: "Other")

      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab

      expect(flow).to have_a_visitor(visitor1, user_visit1)
    end

    it "user should be able to delete a visitor from visitor list", js: true do
      visitor1 = create(:user, :confirmed, first_name: "user1", last_name: "test1")
      user_visit1 = create(:user_visit, visit: visit, user: visitor1, role: "Other")

      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab

      expect(flow).to have_a_visitor(visitor1, user_visit1)
      flow.delete_user_visit(user_visit1)
      expect(flow).to be_not_showing_a_visitor(user_visit1)
    end

    it "should be able to change the add visitor form by clicking on action buttons", js: true do
      create(:institution, id: 2368)
      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab

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
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab

      flow.click_on_change
      flow.change_user_visit_dates(arrives_at: user_visit.arrives_at + 1.day, departs_at: user_visit.departs_at)
      expect(flow).to have_visitor_dates(user_visit, "#{(user_visit.arrives_at + 1.day).strftime('%m/%d/%Y')} - #{user_visit.departs_at.strftime('%m/%d/%Y')}")
    end

    it "should return an error if the visitors date is out of the visit date range", js: true do
      visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
      create(:user_visit, visit: visit, user: visitor, role: "Other")

      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab

      flow.click_on_change
      flow.change_user_visit_dates(arrives_at: visit.start_date - 1.day, departs_at: visit.end_date)
      expect(flow).to have_error_message("must be after visit start date")
    end

    it "has manual user day filed", js: true do
      visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
      create(:user_visit, visit: visit, user: visitor, role: "Other")

      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab
      flow.click_on_change

      expect(flow).to have_manual_input_field
    end
  end

  describe "when on add a team member form", js: true do
    it "adds the team member to the visitors list when 'Add To Visitor List' is clicked" do
      create(:project_team_membership, user: user, project: visit.project)

      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab
      flow.click_add_to_visitor_list

      expect(page).to have_css(".user-visit")
    end
  end

  describe "when on add group form" do
    it "adds the group record to the visitors list when 'Add Group' is clicked", js: true do
      create(:user, id: 1)
      create(:institution, id: 2368)

      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab
      flow.click_on_add_group

      flow.select_facaulty
      flow.set_count
      flow.click_add_guest

      expect(page).to have_css(".user-visit")
    end
  end

  describe "when on add guest form" do
    it "shows suggestions when user name is typed", js: true do
      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab
      flow.click_on_add_guest

      expect(page).to_not have_css(".list-group-item")
      flow.set_guest
      expect(page).to have_css(".list-group-item")
    end

    it "adds user to the visitors list when a user is selected from the suggestions list", js: true do
      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab

      flow.click_on_add_guest
      flow.set_guest
      flow.select_option

      flow.click_add_visitor

      expect(page).to have_css(".user-visit")
    end

    it "show modal to add new guest when no user is selected from the suggestions list", js: true do
      create(:user, id: 1)
      create(:institution, id: 2368)

      sign_in(user)
      flow = VisitShowVisitorTabFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      flow.click_on_vistors_tab
      flow.click_on_add_guest

      flow.click_add_visitor

      expect(flow).to have_modal
      flow.set_modal_guest
      flow.select_facaulty

      flow.click_save_btn

      expect(page).to have_css(".user-visit")
    end
  end
  
  describe "when visit status is incomplete" do
    it "status bar will disable", js: true do
      sign_in(user)
      flow = VisitShowFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      expect(flow).to be_selected_incomplete

      expect(flow).not_to be_clickable_status_bar
    end
  end

  describe "when visit status is not incomplete" do
    it "status bar will not disable", js: true do
      sign_in(user)
      approved_visit = create(:visit, reserve: reserve, status: "approved")
      flow = VisitShowFlow.new(page: page, visit_id: approved_visit.id, reserve_id: reserve.id)

      flow.visit_show_page

      expect(flow).to be_clickable_status_bar
    end
  end

  describe "when email option is default" do
    it "it display text box to compose email", js: true do
      sign_in(user)
      approved_visit = create(:visit, reserve: reserve, status: "approved")
      flow = VisitShowFlow.new(page: page, visit_id: approved_visit.id, reserve_id: reserve.id)

      flow.visit_show_page
      expect(flow).to be_showing_text_area
    end
  end
end
