# frozen_string_literal: true

class Mail::Manager::VisitCancelPresenter < Mail::Manager::VisitNewPresenter
  def email_subject
    "Cancelled Visit - #{visit_reserve_short_name} - #{visit_time_range} - #{visit_applicant_name}".squish
  end

  def visit_reserve_personnel
    visit_reserve
      .personnel
      .includes(:user)
      .receiving_new_visit_or_update_email
      .map { |personnel| PersonnelPresenter.new(personnel) }
  end
end
