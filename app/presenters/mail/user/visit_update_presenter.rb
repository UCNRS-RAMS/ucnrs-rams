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
    "New Visit to the #{visit_reserve_short_name} - #{timeframe} - #{applicant_name}".squish
  end

  def email_bcc_to_list
    personnel_receiving_update_email
      .map(&:email)
      .reject(&:blank?)
  end

  def visit_project
    Mail::User::ProjectPresenter.new(visit.project)
  end

  private

  def personnel_receiving_update_email
    visit_reserve.personnel
      .where(receive_update_email: true)
      .map { |personnel| PersonnelPresenter.new(personnel) }
  end
end
