# frozen_string_literal: true

class Manager::Dashboard::Calendar::AmenityRowPresenter < AmenityVisitPresenter
  include Rails.application.routes.url_helpers

  def initialize(amenity_visit, reserve_id)
    super(amenity_visit)
    @reserve_id = reserve_id
  end

  attr_reader :reserve_id

  def title
    amenity_title
  end

  def units_label
    I18n.t(
      "modals.calendar.visit.units",
      count: number_of_people.to_i,
      unit: unit.to_s.pluralize(number_of_people.to_i),
    )
  end

  def invoiced?
    invoice_id.to_i.positive?
  end

  def invoice_path
    manager_reserve_invoice_path(reserve_id, invoice_id) if invoiced?
  end

  def arrives_label
    short_datetime(arrives)
  end

  def departs_label
    short_datetime(departs)
  end

  private

  def short_datetime(datetime)
    I18n.l(datetime, format: :calendar_short_datetime) if datetime.present?
  end
end
