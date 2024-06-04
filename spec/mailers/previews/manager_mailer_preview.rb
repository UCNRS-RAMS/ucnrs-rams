class ManagerMailerPreview < ActionMailer::Preview
  def visit_new
    ManagerMailer
      .with(presenter:
        Mail::Manager::VisitNewPresenter.new(
          Visit
            .in_review
            .submitted_recent_first
            .where(reserve_id: reserve_ids_with_personnel_email)
            .first
        )
      )
      .visit_new
  end

  def invoice_email
    invoice = Invoice.last
    email_new_presenter = Manager::Invoices::EmailsNewPresenter.new(invoice: invoice)

    pdf_presenter = Manager::Invoices::PdfShowPresenter.new(invoice: invoice)
    html = ActionController::Base.new.render_to_string(
      "manager/invoices/pdf/show", layout: "pdf.html", locals: { presenter: pdf_presenter }
    )
    pdf = WickedPdf.new.pdf_from_string(html)

    email_params.merge!(
      default_subject: email_new_presenter.email_default_subject,
      attachment: pdf,
      attachment_name: email_new_presenter.email_attachment_name
    )

    ManagerMailer
      .with(
        invoice: invoice,
        email_params: email_params,
      )
      .invoice_email
  end

  private

  def reserve_ids_with_personnel_email
    @reserve_ids ||= ReservePersonnel
      .where.not(email: nil)
      .map(&:reserve_id)
      .uniq
  end

  def email_params
    @email_params ||= ActionController::Parameters.new(
      {
        subject: "This is a made up subject",
        body: "invoice email body",
        cc_personnel: true,
        email_to_list: ["email_recipient1@abc.com", "email_recipient2@abc.com"],
      }
    )
  end
end
