class ManagerMailerPreview < ActionMailer::Preview
  def visit_new
    ManagerMailer
      .with(presenter:
        Mail::Manager::VisitNewPresenter.new(
          Visit.in_review.submitted_recent_first.last
        )
      )
      .visit_new
  end
end
