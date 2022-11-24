class InvoicesController < ApplicationController
  def show
    @presenter = InvoicePresenter.new(invoice) 
  end

  private

  def invoice
    Invoice.find(invoice_id)
  end

  def invoice_id
    params.permit(:id).require(:id)
  end
end
