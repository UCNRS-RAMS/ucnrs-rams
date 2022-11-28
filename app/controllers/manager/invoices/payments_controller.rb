class Manager::Invoices::PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  def new
    @form = InvoicePaymentForm.new
    @presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: current_user)
  end

  def create
    @form = InvoicePaymentForm.new(params: invoice_payment_params)
    if @form.save
      invoice.updated_balance
      redirect_to manager_reserve_visit_invoice_path(id: @form.invoice_id)
    else
      @presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: current_user)
      render :new
    end
  end

  private

  def invoice
    Invoice.find_by(id: params[:invoice_id])
  end

  def invoice_payment_params
    params.require(:invoice_payment).permit(
      :invoice_id,
      :user_id,
      :amount,
      :paid_on,
      :payment_type,
      :notes,
      :payor,
    ).merge(user_id: current_user.id)
  end
end
