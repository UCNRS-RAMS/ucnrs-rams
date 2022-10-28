class UserMailerPreview < ActionMailer::Preview
  def visit_new
    UserMailer
      .with(presenter:
        Mail::User::VisitNewPresenter.new(
          Visit.in_review.submitted_recent_first.last
        )
      )
      .visit_new
  end
end
