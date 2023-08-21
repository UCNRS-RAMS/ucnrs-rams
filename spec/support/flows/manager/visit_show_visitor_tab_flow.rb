class VisitShowVisitorTabFlow
  def initialize(page:, visit_id:, reserve_id:)
    @page = page
    @visit_id = visit_id
    @reserve_id = reserve_id
  end

  def visit_show_page
    page.visit("/manager/reserves/#{reserve_id}/visits/#{visit_id}")
  end

  def within(selector, &block)
    begin
      @page_scope = selector
      block.call
    ensure
      @page_scope = nil
    end
  end

  def click_on_vistors_tab
    page.find("#visitors").click
  end

  def visitors_tab_content?
    page.has_css?("#add-visitor")
  end

  def has_a_visitor?(visitor, user_visit)
    within("#user_visit_#{user_visit.id}") do
      page.has_css?("td:nth-child(2)", text: "#{visitor.first_name} #{visitor.last_name}")
      page.has_css?("td:nth-child(5)", text: DateRangePresenter.value(start_date: user_visit.arrives_at, end_date: user_visit.departs_at))
    end
  end

  def delete_user_visit(user_visit)
    within("#user_visit_#{user_visit.id}") do
      page.accept_confirm do
        page.find("td:nth-child(7) > a").click
      end
    end
  end

  def not_showing_a_visitor?(user_visit)
    page.has_no_css?("#user_visit_#{user_visit.id}")
  end

  def has_selected_add_team_member?
    page.has_css?(".selected", text: "Add Team Member")
  end

  def has_section?(css)
    page.has_css?(css)
  end

  def click_on_add_individual
    page.click_link("Add Individual")
  end

  def click_on_add_group
    page.click_link("Add Group")
  end

  def click_on_change
    page.click_link "Change"
  end

  def click_add_visitor
    page.click_button("Add Visitor")
  end

  def has_modal?
    page.has_css?("#modal")
  end

  def change_user_visit_dates(arrives_at:, departs_at:)
    page.fill_in("user_visit_arrives_at", with: arrives_at)
    page.fill_in("user_visit_departs_at", with: departs_at)
    page.find(".buttons>button[type='submit']").click
  end

  def has_visitor_dates?(user_visit, text)
    within("#user_visit_#{user_visit.id}") do
      page.has_css?("td:nth-child(5)", text: text)
    end
  end

  def click_save_btn
    page.click_button("Save")
  end

  def click_add_guest
    page.click_button("Add Group")
  end

  def set_count
    page.find("#user_visit_count").set("4")
  end

  def select_facaulty
    page.find("#user_visit_role").select("Faculty")
  end

  def set_guest
    page.find("#user_visit_guest_name").set("John")
  end

  def set_modal_guest
    page.find("#modal #user_visit_guest_name").set("hafiz")
  end

  def has_manual_input_field?
    page.find("#user_visit_actual_days")
  end

  def click_add_to_visitor_list
    page.click_on("Add To Visitor List")
  end

  def select_option
    page.find("#stimulus-autocomplete-option-0").click
  end

  def has_error_message?(text)
    page.has_css?(".error_messages", text: text)
  end

  private

  attr_reader :page, :reserve_id, :visit_id
end
