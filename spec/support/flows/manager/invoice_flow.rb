class Manager::InvoiceFLow
  def initialize(page:, visit_id:, reserve_id:, invoice_id: nil)
    @page = page
    @visit_id = visit_id
    @reserve_id = reserve_id
    @invoice_id = invoice_id
  end

  def visit_manager_projects_invoice_new_page
    page.visit("/manager/reserves/#{reserve_id}/visits/#{visit_id}/invoices/new")
  end

  def visit_manager_projects_invoice_detail_page
    page.visit("/manager/reserves/#{reserve_id}/visits/#{visit_id}/invoices/#{invoice_id}")
  end

  def visit_manager_projects_invoice_edit_page
    page.visit("/manager/reserves/#{reserve_id}/visits/#{visit_id}/invoices/#{invoice_id}/edit")
  end

  def showing_visit_info?
    page.has_css?(".invoice-visit-info")
  end

  def showing_text?(class_name, text)
    page.has_css?(class_name, text: text)
  end

  def showing_bill_to?
    page.has_css?(".invoice-bill-to")
  end

  def showing_bill_to_table?
    page.has_css?("#invoice-bill-to-table")
  end

  def showing_amenity_visit_table?
    page.has_css?("#amenities-summary-table")
  end

  def showing_amenity_visits?
    page.has_css?(".invoice-amenity-visits")
  end

  def showing_invoice_notes?
    page.has_css?(".invoice-notes")
  end

  def showing_saved_note?
    page.has_css?(".saved-note")
  end

  def click_trash_icon
    page.accept_confirm do
      page.find(".delete").click
    end
  end

  def click_payment_btn
    page.find(".payment-btn").click
  end

  def click_save_btn
    page.click_on("Save")
  end

  def showing_errors?
    page.has_css?(".error")
  end

  def showing_payment_madal?
    page.has_css?(".modal-content")
  end

  def fill_payment_form
    page.find("#invoice_payment_paid_on").set(20-10-2022)
    page.find("#invoice_payment_amount").set(8)
  end

  def deleted_invoice?
    Invoice.find_by(id: invoice_id).nil?
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

  attr_reader :page, :reserve_id, :visit_id, :invoice_id
end
