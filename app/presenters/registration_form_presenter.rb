# frozen_string_literal: true

class RegistrationFormPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  SPECIAL_CHARACTERS_PATTERN = %r{[^0-9A-Za-z]+}
  BEGINNING_OR_END_UNDERSCORE_PATTERN = %r{(?:\A_+|_+\z)}
  PHONE_NUMBER_PLACEHOLDER = "(_ _ _) _ _ _ - _ _ _ _"
  POSTAL_CODE_PLACEHOLDER = "_ _ _ _ _"
  ROLE_WITH_ALLOWED_ADVISOR_OPTIONS = ["research_scientist", "research_assistant", "graduate_student", "undergraduate_student"].freeze

  attr_reader :form

  def initialize(form = nil)
    @form = form || RegistrationForm.new
  end

  delegate :user, to: :form, prefix: true

  def gender_identity_options
    User.gender_identities.map {|key, value| [value, key]}
  end

  def change_password
    link_to I18n.t(".password.change_password"), password_index_path, method: :post
  end

  def age_range_options
    User.age_ranges.map {|key, value| [key, value]}
  end

  def role_options
    User.roles.except(:no_selection).map do |key, value|
      [I18n.t("universal.roles.#{key}"), key]
    end
  end

  def default_country_option
    [default_country.name, default_country.id]
  end

  def default_state_option
    [default_state.name, default_state.id]
  end

  def address_state_options
    State
      .in_country(form_user.address_country_id || default_country)
      .alphabetical_by_name
  end

  def billing_address_state_options
    State
      .in_country(form_user.billing_address_country_id)
      .alphabetical_by_name
  end
  
  def default_gender_identity_option
    gender_identity_options = User.gender_identities
    [gender_identity_options[:prefer_not_to_state], :prefer_not_to_state]
  end

  def phone_number_placeholder
    PHONE_NUMBER_PLACEHOLDER
  end

  def postal_code_placeholder
    POSTAL_CODE_PLACEHOLDER
  end

  def institution_field_value
    form_user&.institution&.name
  end

  def role_with_allowed_advisor_options
    ROLE_WITH_ALLOWED_ADVISOR_OPTIONS
  end

  private

  def identifier_for(field, value)
    value_with_no_special_chars = value
      .downcase
      .gsub(SPECIAL_CHARACTERS_PATTERN, "_")
      .gsub(BEGINNING_OR_END_UNDERSCORE_PATTERN, "")
    [field, value_with_no_special_chars].join("_").to_sym
  end

  def default_country
    Country.find_by(name: "United States")
  end

  def default_state
    State.find_by(name: "California")
  end
end
