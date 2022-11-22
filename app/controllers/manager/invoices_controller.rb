class Manager::InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  def new
    @form = InvoiceForm.new(params: { visit_id: params[:visit_id] })
    @presenter = Manager::Invoices::InvoicesFormPresenter.new(visit: visit, form: @form)
  end

  def create
    @form = InvoiceForm.new(invoice: invoice, params: params)
    if @form.save
      redirect_to manager_reserve_visit_invoice_path(id: @form.invoice_id)
    else
      @presenter = Manager::Invoices::InvoicesFormPresenter.new(visit: visit, form: @form)
      render :new
    end
  end

  def show
    @presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: current_user)
  end

  def destroy
    if invoice.destroy
      redirect_to new_manager_reserve_visit_invoice_path
    end
  end

  private

  def invoice
    Invoice.find_by(id: params[:id]) || Invoice.new(invoice_params)
  end

  def invoice_params
    params.require(:invoice).permit(:notes, :balance_due).merge({
      visit_id: params[:visit_id],
    })
  end

  def visit
    Visit.find(params[:visit_id])
  end
end
