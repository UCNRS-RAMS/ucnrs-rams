class Manager::Visits::InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  layout "manager"

  def index
    @form = InvoiceForm.new(params: { visit_id: params[:visit_id] }, remove_filter: true)
    @presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, invoice_filter: invoice_filter, user: current_user, form: @form)
  end

  private

  def visit
    Visit.find(params[:visit_id])
  end

  def invoice_filter
    params[:invoice_filter]
  end
end
