class Manager::InvoiceFlow
  def initialize(page:, visit_id:, reserve_id:)
    @page = page
    @visit_id = visit_id
    @reserve_id = reserve_id
  end

  def visit_manager_projects_invoice_new_page
    page.visit("/manager/reserves/#{reserve_id}/visits/#{visit_id}/invoices/new")
  end

  def change_number_of_people(id, data)
    page.fill_in("number_of_people#{id}", with: data)
  end

  private

  attr_reader :page, :reserve_id, :visit_id
end
