# frozen_string_literal: true

class Manager::ReserveInfo::ReserveFormPresenter
  def initialize(form = nil)
    @form = form || ReserveForm.new

    set_default_country_selected
    set_default_billing_country_selected
  end

  attr_reader :form

  delegate :reserve, to: :form, prefix: true

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

  def logo
    form_reserve.logo.url(:small) || form_reserve.logo_placeholder
  end

  def hero_photo
    form_reserve.large_hero_photo.url(:small) || form_reserve.large_hero_photo_placeholder
  end

  def listing_photo
    form_reserve.listing_photo.url(:small) || form_reserve.listing_photo_placeholder
  end

  private

  def default_country
    Country.find_by(name: "United States")
  end

  def set_default_country_selected
    form_reserve.address_country_id ||= default_country.id
  end

  def set_default_billing_country_selected
    form_reserve.billing_address_country_id ||= default_country.id
  end
end
