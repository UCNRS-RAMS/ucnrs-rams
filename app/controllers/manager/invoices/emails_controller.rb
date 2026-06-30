class Manager::Invoices::EmailsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator_or_accountant!, only: [:create], unless: -> { super_admin? }

  def new
    @presenter = Manager::Invoices::EmailsNewPresenter.new(
      invoice: invoice,
    )
  end

  def create
    email_new_presenter = Manager::Invoices::EmailsNewPresenter.new(invoice: invoice)
    pdf = create_invoice_pdf(invoice)

    email_params.merge!(
      default_subject: email_new_presenter.email_default_subject,
      attachment: pdf,
      attachment_name: email_new_presenter.email_attachment_name,
    )

    send_invoice_email!(invoice: invoice, email_params: email_params)

    flash[:notice] = "Invoice has been successfully emailed."
    redirect_to manager_reserve_invoice_path(current_reserve, invoice)
  end

  private

  def invoice
    Invoice.find_by(id: params[:invoice_id])
  end

  def create_invoice_pdf(invoice)
    pdf_presenter = Manager::Invoices::PdfShowPresenter.new(invoice: invoice)
    html = render_to_string("manager/invoices/pdf/show", layout: "pdf", locals: { presenter: pdf_presenter })

    return WickedPdf.new.pdf_from_string(html)
  end

  def email_params
    @email_params ||= params.require(:invoice_email).permit(
      :subject,
      :body,
      :cc_personnel,
      email_to_list: [],
    )
  end

  def send_invoice_email!(invoice:, email_params:)
    ManagerMailer
      .with(
        invoice: invoice,
        email_params: email_params,
      )
      .invoice_email
      .deliver_later
  end
end
