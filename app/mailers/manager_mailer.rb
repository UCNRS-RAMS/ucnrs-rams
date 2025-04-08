class ManagerMailer < ApplicationMailer
  layout "mailer"

  def visit_new
    @presenter = params[:presenter]

    return if @presenter.visit_reserve_personnel_emails.blank?

    mail(
      to: @presenter.visit_reserve_personnel_emails,
      reply_to: @presenter.visit_applicant_email,
      subject: @presenter.email_subject,
      content_type: "text/html",
    )
  end

  def invoice_email
    @presenter = Mail::Manager::InvoiceEmailPresenter.new(
      invoice: params[:invoice],
      email_params: params[:email_params],
    )

    attachments[@presenter.email_attachment_name] = {
      mime_type: "application/pdf",
      content: @presenter.email_attachment,
    }

    mail(
      to: @presenter.email_to,
      cc: @presenter.email_cc,
      subject: @presenter.email_subject,
    )
  end

  def iacuc_notification_email
    @presenter = Mail::Manager::IacucNotificationEmailPresenter.new(
      params[:visit],
    )

    mail(
      to: params[:personnel_email_list],
      subject: "IACUC notification",
    )

    LogForm2.create(
      params: {
        about: "iacuc",
        action: "email sent",
        record: @presenter.visit.project,
        user: :system,
        reserve: @presenter.visit.reserve,
        comment: "::email:: sent to #{ params[:personnel_email_list] }"
      }
    )
  end

  def drone_notification_email
    @presenter = Mail::Manager::DroneNotificationEmailPresenter.new(
      params[:visit],
    )

    mail(
      to: params[:personnel_email_list],
      subject: "Drone notification",
    )

    LogForm2.create(
      params: {
        about: "drone",
        action: "email sent",
        record: @presenter.visit.project,
        user: :system,
        reserve: @presenter.visit.reserve,
        comment: "::email:: sent to #{ params[:personnel_email_list] }"
      }
    )
  end

  def scuba_notification_email
    @presenter = Mail::Manager::ScubaNotificationEmailPresenter.new(
      params[:visit],
    )

    mail(
      to: params[:personnel_email_list],
      subject: "Scuba notification",
    )

    LogForm2.create(
      params: {
        about: "scuba",
        action: "email sent",
        record: @presenter.visit.project,
        user: :system,
        reserve: @presenter.visit.reserve,
        comment: "::email:: sent to #{ params[:personnel_email_list] }"
      }
    )
  end

  private
end
