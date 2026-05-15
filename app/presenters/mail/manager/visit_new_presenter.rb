# frozen_string_literal: true

class Mail::Manager::VisitNewPresenter < Mail::VisitNewPresenter
  

  delegate :name,
    :short_name,
    :managing_campus,
    to: :visit_reserve,
    prefix: true

  def email_subject
    "New Visit - #{visit_reserve_short_name} - #{visit_time_range} - #{visit_applicant_name}".squish
  end

  def visit_reserve_personnel
    visit_reserve
      .personnel
      .includes(:user)
      .receiving_new_visit_email
      .map { |personnel| PersonnelPresenter.new(personnel) }
  end

  def visit_reserve_personnel_emails
    visit_reserve_personnel
      .map { |personnel| personnel.user.email }
      .reject(&:blank?)
  end

  private

  def visit_time_range
    DateRangePresenter.value(start_date: visit.starts_at, end_date: visit.ends_at)
  end
end
