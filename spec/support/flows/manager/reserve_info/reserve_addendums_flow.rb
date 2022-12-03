class Manager::ReserveInfo::ReserveAddendumsFlow
  def initialize(page, reserve, user)
    @page = page
    @reserve = reserve
    @user = user
  end

  def visit_manager_reserve_info_reserve_addendums_index_page(reserve)
    page.visit("/manager/reserves/#{reserve.id}/reserve_info/reserve_addendums")
  end

  def on_manager_reserve_info_reserve_addendums_index_page?
    page.has_css?("body.manager.reserve_addendums.reserve_addendums-index")
  end

  def click_new_reserve_addendum
    page.find("#reserve-addendums-table a", text: "New").click
  end

  def has_new_reserve_addendum_modal_displayed?
    page.has_css?(".modal-content h2", text: "New Reserve Addendum", visible: true)
  end

  def fill_out_reserve_addendum_form(
    sort_order: 1,
    name: "addendum name",
    content: "addendum content"
  )
    page.fill_in("Sort Order", with: sort_order)
    page.fill_in("Name", with: name)
    page.find("#reserve_addendum_content", visible: :all).click.set(content)
  end

  def click_modal_button(name)
    page.find(".modal-content button", text: name).click
  end

  def has_reserve_addendums_table_cell_containing?(name)
    page.has_css?("table#reserve-addendums-table td", text: name)
  end

  def click_edit_reserve_addendum(reserve_addendum)
    page.find("#reserve_addendum_#{reserve_addendum.id} a", text: "Edit").click
  end

  def has_edit_reserve_addendum_modal_displayed?
    page.has_css?(".modal-content h2", text: "Edit Reserve Addendum", visible: true)
  end

  private

  attr_reader :page
end
