# frozen_string_literal: true

class Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :amenity, to: :form, prefix: true

  def units_type_options
    Amenity.units_types.map { |key, _value| [translate(:units_types, key), key] }
  end

  def time_type_options
    Amenity.time_types.map { |key, _value| [translate(:time_types, key), key] }
  end

  def amenities_group_options
    reserve = Reserve.find_by(id: form_amenity.reserve)
    (1..5).map { |i| [reserve&.public_send("amenity_group_label_#{i}"), i.to_s] }
  end

  def listing_photo
    form_amenity.listing_photo.url(:medium) || form_amenity.listing_photo_placeholder
  end

  private

  def translate(column, key)
    I18n.t("universal.amenity.#{column}.#{key}")
  end
end
