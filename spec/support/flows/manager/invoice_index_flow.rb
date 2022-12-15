class Manager::InvoiceIndexFlow
  def initialize(page)
    @page = page
  end

  def visit_manager_invoice_index_page(reserve)
    page.visit("/manager/reserves/#{reserve.id}/invoices")
  end

  def on_manager_invoice_index_page?
    page.has_css?("body.manager.invoices.invoices-index")
  end

  def has_active_invoices_tab?
    page.has_css?("a.nav-link.active", text: "Invoices")
  end

  def has_displayed_invoices?(number)
    page.has_selector?("tr.invoice", count: number)
  end

  def has_pagination_link?(text)
    page.has_css?("span.#{text}")
  end

  def has_selected_page_number_link?(number)
    page.has_css?("span.current", text: number)
  end

  def has_page_number_link?(number)
    page.has_css?("span.page a", text: number)
  end

  def go_to_page(page_number)
    resize_window
    page.find("a", text: page_number).click
  end
  
  def go_to_last_page
    resize_window
    page.find("span.last a").click
  end

  def go_to_last_page
    resize_window
    page.find("span.last a").click
  end

  private

  attr_reader :page

  def resize_window
    Capybara.current_session.current_window.resize_to(1000, 1000)
  end
end
