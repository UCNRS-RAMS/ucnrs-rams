class UserMailer < ApplicationMailer
  layout "mailer"

  def visit_new
    @presenter = params[:presenter]

    mail(
      to: [@presenter.visit_applicant_email],
      subject: @presenter.email_subject,
      content_type: "text/html",
    )
  end

  def project_complete
    @presenter = params[:presenter]

    mail(
      to: @presenter.team_member_emails,
      subject: @presenter.email_subject,
      content_type: "text/html",
    )
  end
end
