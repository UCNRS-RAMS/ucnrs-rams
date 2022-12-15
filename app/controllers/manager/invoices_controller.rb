class Manager::InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  layout "manager"

  def index
    @presenter = Manager::InvoicesIndexPresenter.new(reserve: current_reserve, user: current_user, page: page_number, filter: filter)
  end

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
      flash.now[:alert] = I18n.translate("manager.no_amenity_visit") if !@form.has_amenity_visit?
      render :new
    end
  end

  def edit
    form = InvoiceForm.new(invoice: invoice, params: { visit_id: params[:visit_id] }, editing: true)
    @presenter = Manager::Invoices::InvoiceEditPresenter.new(visit: visit, invoice: invoice, form: form)
  end

  def update
    @form = InvoiceForm.new(invoice: invoice, params: params, editing: true)    
    if @form.save
      redirect_to manager_reserve_visit_invoice_path(id: @form.invoice_id)
    else
      @presenter = Manager::Invoices::InvoiceEditPresenter.new(visit: visit, invoice: invoice, form: @form)
      render :edit
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
    visit.invoices.find_by(id: params[:id])
  end

  def visit
    Visit.find(params[:visit_id])
  end

  def page_number
    params[:page]
  end

  def filter
    if params[:filter].present?
      params.require(:filter).permit(
        :reserve,
        :invoice_search,
        :invoice_status,
        :date_range_type,
        :visit_date_begin,
        :visit_date_end,
        :invoice_date_end,
        :invoice_date_begin,
        :sort_by
      )
    end
  end
end
