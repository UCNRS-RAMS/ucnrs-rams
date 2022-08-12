class AddVisitorsFlow
  def initialize(page)
    @capybara_page = page
    @page_scope = nil
  end

  def visit_add_visitors_page(visit_id)
    page.visit("/visits/#{visit_id}/user_visits")
  end

  def page
    if @page_scope
      capybara_page.find(@page_scope)
    else
      capybara_page
    end
  end

  def within(selector, &block)
    begin
      @page_scope = selector
      block.call
    ensure
      @page_scope = nil
    end
  end

  def has_a_visitor?(visitor, user_visit)
    within("#user_visit_#{user_visit.id}") do
      page.has_css?("td:nth-child(2)", text: "#{visitor.first_name} #{visitor.last_name}")
      page.has_css?("td:nth-child(5)", text: "#{user_visit.arrives_at.strftime('%m/%d/%Y')} - #{user_visit.departs_at.strftime('%m/%d/%Y')}")
    end
  end

  def delete_user_visit(user_visit)
    page.accept_confirm do
      within("#user_visit_#{user_visit.id}") do
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

  def click_on_add_guest
    page.click_link("Add Guest")
  end

  def click_on_add_group
    page.click_link("Add Group")
  end

  def has_section?(css)
    page.has_css?(css)
  end

  def has_css?(css_class)
    page.has_css?(css_class)
  end

  def click_on_change(user_visit)
    within "#user_visit_#{user_visit.id}" do
      page.click_link "Change"
    end
  end

  def change_user_visit_dates(arrives_at:, departs_at:)
    page.fill_in("user_visit_arrives_at", with: arrives_at)
    page.fill_in("user_visit_departs_at", with: departs_at)
    page.find(".buttons>button[type='submit']").click
  end

  def has_visitor_dates?(user_visit, text)
    within "#user_visit_#{user_visit.id}" do
      page.has_css?("td:nth-child(5)", text: text)
    end
  end

  def has_error_message?(text)
    page.has_css?(".error_messages", text: text)
  end

  private

  attr_reader :capybara_page
end
