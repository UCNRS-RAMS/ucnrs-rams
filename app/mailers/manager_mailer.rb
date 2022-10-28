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
end
