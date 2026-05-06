class Manager::InvoicesController < Manager::ApplicationController
  include VisitScopedToReserve

  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :confirm_visit_in_reserve!, only: [:new, :create]
  before_action :confirm_invoice_in_reserve!, only: [:show, :edit, :update, :destroy]
  before_action :is_administrator_or_accountant!, only: [:create, :update, :destroy], unless: -> { super_admin? }

  layout "manager"

  def index
    @presenter = Manager::InvoicesIndexPresenter.new(
      reserve: current_reserve,
      user: current_user,
      page: page_number,
      filter: filter,
    )
  end

  def new
    @form = InvoiceForm.new(params: { visit_id: params[:visit_id] })
    @presenter = Manager::Invoices::InvoicesFormPresenter.new(visit: visit, form: @form)
  end

  def create
    @form = InvoiceForm.new(invoice: invoice, params: params)

    if @form.save
      create_log(action: :created, invoice: @form.invoice, visit: @form.visit)
      redirect_to manager_reserve_invoice_path(current_reserve, @form.invoice_id)
    else
      @presenter = Manager::Invoices::InvoicesFormPresenter.new(visit: visit, form: @form)
      flash.now[:alert] = I18n.translate("manager.no_amenity_visit") if !@form.has_amenity_visit?
      render :new
    end
  end

  def edit
    form = InvoiceForm.new(
      invoice: invoice,
      params: { visit_id: invoice.visit_id },
      editing: true,
      remove_filter: true,
    )
    @presenter = Manager::Invoices::InvoiceEditPresenter.new(
      visit: visit,
      invoice: invoice,
      form: form,
    )
  end

  def update
    @form = InvoiceForm.new(invoice: invoice, params: params, editing: true)
    if @form.save
      redirect_to manager_reserve_invoice_path(current_reserve, @form.invoice_id)
    else
      @presenter = Manager::Invoices::InvoiceEditPresenter.new(
        visit: visit,
        invoice: invoice,
        form: @form,
      )
      render :edit
    end
  end

  def show
    @presenter = Manager::Invoices::InvoiceShowPresenter.new(
      invoice: invoice,
      current_user: current_user,
    )
  end

  def destroy
    visit_id = invoice.visit_id
    if invoice.destroy
      redirect_to new_manager_reserve_visit_invoice_path(current_reserve, visit_id)
    end
  end

  private

  def confirm_invoice_in_reserve!
    return true if invoice.visit.reserve_id == current_reserve.id

    respond_to_modal_turbo_frame(flash_msg: I18n.translate("manager.not_authorize"))
  end

  def invoice
    return nil if params[:id].blank?

    @invoice ||= Invoice.find(params[:id])
  end

  def visit
    @visit ||= params[:visit_id] ? Visit.find(params[:visit_id]) : invoice.visit
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
        :sort_by,
      )
    end
  end

  private

  def create_log(action:, invoice:, visit: nil)
    LogForm.create(
      params: {
        action: action,
        user_id: current_user.id,
      },
      record: invoice,
      record_about: visit,
    )
  end
end
