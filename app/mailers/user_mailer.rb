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
end
