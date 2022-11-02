require "rails_helper"

RSpec.describe "Manager - Reserve Info" do
  describe "editing amenity group names" do
    it "successfully change amenity group names", js: true do
      user = create(:user, :confirmed)
      reserve = create(:reserve,
        amenity_group_label_1: "label 1",
        amenity_group_label_2: "label 2",
        amenity_group_label_3: "label 3",
        amenity_group_label_4: "label 4",
        amenity_group_label_5: "label 5",
      )
      create(:reserve_personnel, user: user, reserve: reserve)

      flow = Manager::ReserveInfo::ReserveDetailsFlow.new(page, reserve, user)
      sign_in(user)

      flow.visit_manager_reserve_info_amenities_and_rates_index_page(reserve)
      expect(flow).to be_on_manager_reserve_info_amenities_and_rates_index_page

      flow.click_new_amentity
      expect(flow).to have_new_amenity_modal_displayed
      expect(flow).to have_amenity_group_option_texts(
        ["label 1", "label 2", "label 3", "label 4", "label 5",]
      )

      flow.visit_manager_reserve_info_reserve_details_edit_page(reserve)
      expect(flow).to be_on_manager_reserve_info_reserve_details_edit_page
      expect(flow).to have_amenity_group_name(1, "label 1")
      expect(flow).to have_amenity_group_name(2, "label 2")
      expect(flow).to have_amenity_group_name(3, "label 3")
      expect(flow).to have_amenity_group_name(4, "label 4")
      expect(flow).to have_amenity_group_name(5, "label 5")

      flow.enter_name_into_amenity_group_name(1, "new label 1")
      flow.enter_name_into_amenity_group_name(2, "new label 2")
      flow.enter_name_into_amenity_group_name(3, "new label 3")
      flow.enter_name_into_amenity_group_name(4, "new label 4")
      flow.enter_name_into_amenity_group_name(5, "new label 5")
      flow.submit_reserve_detail_form

      flow.visit_manager_reserve_info_amenities_and_rates_index_page(reserve)
      expect(flow).to be_on_manager_reserve_info_amenities_and_rates_index_page

      flow.click_new_amentity
      expect(flow).to have_new_amenity_modal_displayed
      expect(flow).to have_amenity_group_option_texts(
        ["new label 1", "new label 2", "new label 3", "new label 4", "new label 5",]
      )
    end
  end

  describe "uploading reserve images" do
    it "can attach large hero and listing images to a reserve" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      flow = Manager::ReserveInfo::ReserveDetailsFlow.new(page, reserve, user)

      sign_in(user)
      flow.visit_manager_reserve_info_reserve_details_edit_page(reserve)
      expect(flow).to be_on_manager_reserve_info_reserve_details_edit_page

      flow.select_photo_to_upload("large_hero")
      flow.select_photo_to_upload("listing")
      flow.click_save_changes_button
      expect(flow).to have_flash_message("Update success.")

      reserve.reload
      expect(reserve.listing_photo_url).to match(/\/ucnrs-test\/reserve_id_#{reserve.id}\/test-image.jpeg/)
      expect(reserve.large_hero_photo_url).to match(/\/ucnrs-test\/reserve_id_#{reserve.id}\/test-image.jpeg/)
    end
  end
end
