class Manager::Invoices::PaymentsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator_or_accountant!, only: [:create, :update]

  def new
    @form = InvoicePaymentForm.new
    @presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: current_user)
  end

  def create
    @form = InvoicePaymentForm.new(params: invoice_payment_params)
    if @form.save
      invoice.updated_balance
      redirect_to edit_manager_reserve_visit_invoice_path(id: @form.invoice_id)
    else
      @presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: current_user)
      render :new
    end
  end

  def edit
    @form = InvoicePaymentForm.new(params: { id: params[:id]}, editing: true)
    @presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: current_user)
  end

  def update
    @form = InvoicePaymentForm.new(params: invoice_payment_params, editing: true)
    if @form.save
      invoice.updated_balance
      redirect_to edit_manager_reserve_visit_invoice_path(id: @form.invoice_id)
    else
      @presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: current_user)
      render :edit
    end
  end

  def destroy
    if invoice_payment.destroy
      redirect_to edit_manager_reserve_visit_invoice_path(id: params[:invoice_id])
    end
  end

  private

  def invoice
    Invoice.find_by(id: params[:invoice_id])
  end

  def invoice_payment
    InvoicePayment.find_by(id: params[:id])
  end

  def invoice_payment_params
    params.require(:invoice_payment).permit(
      :id,
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
