class ManagerMailerPreview < ActionMailer::Preview
  def visit_new
    ManagerMailer
      .with(presenter:
        Mail::Manager::VisitNewPresenter.new(
          Visit
            .in_review
            .submitted_recent_first
            .where(reserve_id: reserve_ids_with_personnel_email)
            .last
        )
      )
      .visit_new
  end

  private

  def reserve_ids_with_personnel_email
    ReservePersonnel
      .where.not(email: nil)
      .map(&:reserve_id)
      .uniq
  end
end
