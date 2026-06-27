class ManagerMailer < ApplicationMailer
  layout "mailer"

  after_deliver :log_notification_email, if: :notification_email?

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

  def visit_cancel
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
  end

  def drone_notification_email
    @presenter = Mail::Manager::DroneNotificationEmailPresenter.new(
      params[:visit],
    )

    mail(
      to: params[:personnel_email_list],
      subject: "Drone notification",
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
  end

  private

  NOTIFICATION_ACTIONS = %w[iacuc_notification_email drone_notification_email
                            scuba_notification_email].freeze
  private_constant :NOTIFICATION_ACTIONS

  def notification_email?
    NOTIFICATION_ACTIONS.include?(action_name)
  end

  def notification_about
    action_name.delete_suffix("_notification_email")
  end

  def log_notification_email
    LogForm2.create(
      params: {
        about: notification_about,
        action: "email sent",
        record: @presenter.visit.project,
        user: :system,
        reserve: @presenter.visit.reserve,
        comment: "::email:: sent to #{params[:personnel_email_list]}",
      }
    )
  end
end
