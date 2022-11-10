class Manager::InvoiceFLow
  def initialize(page:, visit_id:, reserve_id:)
    @page = page
    @visit_id = visit_id
    @reserve_id = reserve_id
  end

  def visit_manager_projects_invoice_new_page
    page.visit("/manager/reserves/#{reserve_id}/visits/#{visit_id}/invoices/new")
  end

  def showing_visit_info?
    page.has_css?(".visit-info")
  end

  def showing_text?(class_name, text)
    page.has_css?(class_name, text: text)
  end

  def showing_bill_to?
    page.has_css?(".bill-to")
  end

  def showing_amenity_visits?
    page.has_css?(".invoice-amenity-visits")
  end

  def showing_invoice_notes?
    page.has_css?(".invoice-notes")
  end

  def showing_notes_field?
    page.has_css?("textarea#invoice_notes")
  end

  def has_submit_button?(text)
    page.has_css?("button.active", text: text)
  end

  def has_back_link?(text)
    page.has_css?("a", text: text)
  end

  def change_arrives_date(id, date)
    page.fill_in("arrives#{id}", with: date)
  end

  def change_number_of_people(id, data)
    page.fill_in("number_of_people#{id}", with: data)
  end

  def change_departs_date(id, date)
    page.fill_in("departs#{id}", with: date)
  end

  private

  attr_reader :page, :reserve_id, :visit_id
end
