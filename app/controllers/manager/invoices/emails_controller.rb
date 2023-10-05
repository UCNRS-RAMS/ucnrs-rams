class Manager::Invoices::EmailsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator_or_accountant!, only: [:create, :update]

  def new
    @presenter = Manager::Invoices::EmailsNewPresenter.new(
      invoice: invoice,
    )
  end

  def create

  end

  private

  def invoice
    Invoice.find_by(id: params[:invoice_id])
  end

  def email_params
    params.require(:email).permit(
      :body
    )
  end
end
