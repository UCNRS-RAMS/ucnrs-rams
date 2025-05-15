# frozen_string_literal: true

class Mail::User::VisitUpdatePresenter
  def initialize(visit)
    @visit = Mail::VisitPresenter.new(visit)
  end

  attr_reader :visit

  delegate_missing_to :visit

  delegate :visit_reserve, to: :visit
  delegate :name,
    :short_name,
    :address_line_1,
    :address_line_2,
    :address_line_3,
    :country,
    :phone_number,
    :email_address,
    to: :visit_reserve,
    prefix: true

  delegate :visit_applicant, to: :visit
  delegate :email, to: :visit_applicant, prefix: true

  delegate :visit_reserve_managing_campus, to: :visit
  delegate :name, to: :visit_reserve_managing_campus, prefix: true

  def email_subject
    "Update for Visit to the #{visit_reserve_short_name} - #{visit_time_range} - #{applicant_name}".squish
  end

  def email_bcc_to_list
    personnel_receiving_update_email
      .map { |personnel| personnel.user_email }
      .reject(&:blank?)
  end

  def visit_project
    Mail::User::ProjectPresenter.new(visit.project)
  end

  private

  def personnel_receiving_update_email
    visit_reserve
      .personnel
      .includes(:user)
      .where(receive_update_email: true)
      .map { |personnel| PersonnelPresenter.new(personnel) }
  end

  def visit_time_range
    DateRangePresenter.value(start_date: visit.starts_at, end_date: visit.ends_at)
  end
end
