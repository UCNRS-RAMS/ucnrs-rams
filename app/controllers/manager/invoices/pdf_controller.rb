class Manager::Invoices::PdfController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  def show
    @presenter = Manager::Invoices::PdfShowPresenter.new(
      invoice: invoice
    )

    render pdf: "rams_invoice_#{invoice.id}",
      disposition: "inline",
      layout: "pdf.html",
      show_as_html: params[:debug].present?
  end

  private

  def invoice
    Invoice.find_by(id: params[:invoice_id])
  end
end
