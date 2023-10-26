class InvoicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @presenter = Invoices::InvoiceShowPresenter.new(
      invoice: invoice,
    )
  end

  private

  def invoice
    Invoice.find(invoice_id)
  end

  def invoice_id
    params.permit(:id).require(:id)
  end
end
