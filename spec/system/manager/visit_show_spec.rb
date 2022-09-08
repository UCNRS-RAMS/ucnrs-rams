require "rails_helper"

RSpec.describe "Manager Visit Show" do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve, name: "Test Reserve") }
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

    it "render summary partial when click on status button", js:true do
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
end
