require "rails_helper"

RSpec.describe "Manager - Reserve Info - More Information" do
  describe "new" do
    it "successfully create reserve addendum", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)

      flow = Manager::ReserveInfo::ReserveAddendumsFlow.new(page, reserve, user)
      sign_in(user)

      flow.visit_manager_reserve_info_reserve_addendums_index_page(reserve)
      expect(flow).to be_on_manager_reserve_info_reserve_addendums_index_page

      flow.click_new_reserve_addendum
      expect(flow).to have_new_reserve_addendum_modal_displayed

      flow.fill_out_reserve_addendum_form(
        sort_order: 100,
        name: "new addendum",
        content: "new addendum content",
      )
      flow.click_modal_button("Create")
      expect(flow).to have_reserve_addendums_table_cell_containing("100")
      expect(flow).to have_reserve_addendums_table_cell_containing("new addendum")
      expect(flow).not_to have_new_reserve_addendum_modal_displayed
    end
  end

  describe "edit" do
    it "successfully update reserve addendum", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      reserve_addendum = create(:reserve_addendum, reserve: reserve, sort_order: 10, name: "old addendum name")
      create(:reserve_personnel, user: user, reserve: reserve)

      flow = Manager::ReserveInfo::ReserveAddendumsFlow.new(page, reserve, user)
      sign_in(user)

      flow.visit_manager_reserve_info_reserve_addendums_index_page(reserve)
      expect(flow).to be_on_manager_reserve_info_reserve_addendums_index_page

      flow.click_edit_reserve_addendum(reserve_addendum)
      expect(flow).to have_edit_reserve_addendum_modal_displayed

      flow.fill_out_reserve_addendum_form(
        sort_order: 100,
        name: "new addendum",
        content: "new addendum content",
      )
      flow.click_modal_button("Update")
      expect(flow).to have_reserve_addendums_table_cell_containing("100")
      expect(flow).to have_reserve_addendums_table_cell_containing("new addendum")
      expect(flow).not_to have_edit_reserve_addendum_modal_displayed
    end
  end
end
