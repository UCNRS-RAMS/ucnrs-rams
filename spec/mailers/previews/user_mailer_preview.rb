class UserMailerPreview < ActionMailer::Preview
  def visit_new
    UserMailer
      .with(presenter:
        Mail::User::VisitNewPresenter.new(
          Visit
            .in_review
            .submitted_recent_first
            .where(reserve_id: reserve_ids_with_personnel_email)
            .last
        )
      )
      .visit_new
  end

  def visit_update
    test_approval_message = <<-approval_message
      approval message here
      line 2
      line 3
      *************
      line 4
    approval_message

    UserMailer
      .with(
        visit: Visit.where(reserve_id: reserve_ids_with_personnel_email).last,
        approval_message: test_approval_message,
        email_to_list: ["user0@not.real", "user1@not.real"]
      )
      .visit_update
  end

  private

  def reserve_ids_with_personnel_email
    @reserve_ids ||= ReservePersonnel
      .where.not(email: nil)
      .map(&:reserve_id)
      .uniq
  end
end
