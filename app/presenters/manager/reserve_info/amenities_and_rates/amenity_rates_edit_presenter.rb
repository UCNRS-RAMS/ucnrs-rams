# frozen_string_literal: true

class Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :amenity, to: :form, prefix: true

  def amenity_name
    form_amenity.title
  end

  def amenity_rates
    form_amenity
      .amenity_rates
      .map{ |amenity_rate| AmenityRatePresenter.new(amenity_rate) }
  end
end
