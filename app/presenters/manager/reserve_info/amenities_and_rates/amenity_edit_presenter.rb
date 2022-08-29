# frozen_string_literal: true

class Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :amenity, to: :form, prefix: true

  def units_type_options
    Amenity.units_types.map { |key, value| [translate(key), key] }
  end

  def time_type_options
    Amenity.time_types.map { |key, value| [translate(key), key] }
  end

  def amenities_type_options
    Amenity.amenities_types.map { |key, value| [translate(key), key] }
  end

  private

  def translate(key)
    I18n.t("manager.reserve_info.amenities_and_rates.amenities.amenity_field.#{key}")
  end
end
