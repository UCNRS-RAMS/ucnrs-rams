class UserMailerPreview < ActionMailer::Preview
  def visit_new
    UserMailer
      .with(presenter:
        Mail::User::VisitNewPresenter.new(
          Visit
            .in_review
            .submitted_recent_first
            .first
        )
      )
      .visit_new
  end

  def visit_update
    test_approval_message = <<-APPROVAL_MESSAGE
      approval message here
      line 2
      line 3
      *************
      line 4
    APPROVAL_MESSAGE

    UserMailer
      .with(
        visit: Visit.last,
        approval_message: test_approval_message,
        email_to_list: ["user0@not.real", "user1@not.real"]
      )
      .visit_update
  end

  def project_contact_manager
    UserMailer
      .with(
        project: Project.last,
        reserve: Reserve.last,
        user: User.last,
      )
      .project_contact_manager
  end

  private

  def reserve_ids_with_personnel_email
    @reserve_ids ||= ReservePersonnel
      .where.not(email: nil)
      .map(&:reserve_id)
      .uniq
  end
end
