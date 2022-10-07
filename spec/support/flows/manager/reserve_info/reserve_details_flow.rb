class Manager::ReserveInfo::ReserveDetailsFlow
  def initialize(page, reserve, user)
    @page = page
    @reserve = reserve
    @user = user
  end

  def visit_manager_reserve_info_reserve_details_edit_page(reserve)
    page.visit("/manager/reserves/#{reserve.id}/reserve_info/reserve_details/edit")
  end

  def on_manager_reserve_info_reserve_details_edit_page?
    page.has_css?("body.manager.reserve_details.reserve_details-edit")
  end

  def has_amenity_group_name?(number, text)
    page.find("input#reserve_amenity_group_label_#{number}").value == text
  end

  def enter_name_into_amenity_group_name(number, text)
    page.fill_in("reserve_amenity_group_label_#{number}", with: text)
  end

  def submit_reserve_detail_form
    page.first("button", text: "Save Changes").click
  end

  def visit_manager_reserve_info_amenities_and_rates_index_page(reserve)
    page.visit("/manager/reserves/#{reserve.id}/reserve_info/amenities_and_rates")
  end

  def on_manager_reserve_info_amenities_and_rates_index_page?
    page.has_css?("body.manager.amenities_and_rates.amenities_and_rates-index")
  end

  def click_new_amentity
    page.find(".amenities-table a", text: "New").click
  end

  def has_new_amenity_modal_displayed?
    page.has_css?(".modal-content h2", text: "New Amenity", visible: true)
  end

  def has_amenity_group_option_texts?(array)
    page.find("select#amenity_group_number").all("option").map(&:text).drop(1) == array
  end

  private

  attr_reader :page
end
