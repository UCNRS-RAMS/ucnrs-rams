# frozen_string_literal: true

class Manager::ReserveInfo::AmenitiesAndRates::AmenityRateCategoryEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :amenity_rate_category, to: :form, prefix: true
end
