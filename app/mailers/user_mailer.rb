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

  def visit_update
    @presenter = Mail::User::VisitUpdatePresenter.new(params[:visit])
    @approval_message = params[:approval_message]
    email_to_list = params[:email_to_list]
    bcc = if params[:bcc_personnel]
      @presenter.email_bcc_to_list
    end

    mail(
      to: email_to_list,
      bcc: bcc,
      subject: @presenter.email_subject,
      content_type: "text/html",
    )
  end

  def project_contact_manager
    @presenter = Mail::User::ProjectContactManagerPresenter.new(
      project: params[:project],
      reserve: params[:reserve],
      user: params[:user],
    )

    mail(
      to: @presenter.email_to,
      subject: @presenter.email_subject,
      content_type: "text/html",
    )
  end
end
