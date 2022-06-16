# frozen_string_literal: true

class Manager::ReserveInfo::ReserveFormPresenter
  HERO_PLACEHOLDER = "reserve-hero-placeholder.jpg"
  LISTING_PLACEHOLDER = "reserve_placeholder.jpg"

  attr_reader :form

  delegate :reserve, to: :form, prefix: true

  def initialize(form = nil)
    @form = form || ReserveForm.new
  end

  def reserve_name
    form_reserve&.name
  end

  def managing_campus_name
    form_reserve&.managing_campus&.name
  end

  def address_state_options
    State
      .in_country(form_reserve.address_country_id)
      .alphabetical_by_name
  end

  def billing_address_state_options
    State
      .in_country(form_reserve.billing_address_country_id)
      .alphabetical_by_name
  end

  def hero_photo
    if form_reserve.large_hero_photo.attached?
      Rails.application.routes.url_helpers.rails_blob_path(form_reserve.large_hero_photo, only_path: true)
    else
      HERO_PLACEHOLDER
    end
  end

  def listing_photo
    if form_reserve.listing_photo.attached?
      Rails.application.routes.url_helpers.rails_blob_path(form_reserve.listing_photo, only_path: true)
    else
      LISTING_PLACEHOLDER
    end
  end

  private

  def default_country
    Country.find_by(name: "United States")
  end
end
