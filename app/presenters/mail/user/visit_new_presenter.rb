# frozen_string_literal: true

class Mail::User::VisitNewPresenter < Mail::VisitNewPresenter
  def initialize(visit)
    super(visit)
  end

  delegate :name,
    :short_name,
    :address_line_1,
    :address_line_2,
    :address_line_3,
    :managing_campus,
    :country,
    :phone_number,
    :email_address,
    :personnel,
    to: :visit_reserve,
    prefix: true

  def email_subject
    "New Visit to the #{reserve_short_name} - #{timeframe} - #{visit_applicant_name}".squish
  end

  def visit_reserve_managing_campus_name
    visit_reserve_managing_campus.name
  end
end
