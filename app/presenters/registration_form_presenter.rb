# frozen_string_literal: true

class RegistrationFormPresenter
  SPECIAL_CHARACTERS_PATTERN = %r{[^0-9A-Za-z]+}
  BEGINNING_OR_END_UNDERSCORE_PATTERN = %r{(?:\A_+|_+\z)}
  PHONE_NUMBER_PLACEHOLDER = "(_ _ _) _ _ _ - _ _ _ _"
  POSTAL_CODE_PLACEHOLDER = "_ _ _ _ _"

  attr_reader :form

  def initialize(form = nil)
    @form = form || RegistrationForm.new
  end

  delegate :user, to: :form, prefix: true

  def gender_identity_options
    gender_identity_options = User.gender_identities
    gender_identity_options.map do |key, value|
      [value, gender_identity_options.key(value)]
    end
  end

  def age_range_options
    User.age_ranges.map do |key, value|
      [value, identifier_for(:age_range, value)]
    end
  end

  def role_options
    User.roles.map do |key, value|
      [value, identifier_for(:role, value)]
    end
  end

  def selected_country_option
    united_states = Country.find_by(name: "United States")
    [united_states.name, united_states.id]
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

  private

  def identifier_for(field, value)
    value_with_no_special_chars = value
      .downcase
      .gsub(SPECIAL_CHARACTERS_PATTERN, "_")
      .gsub(BEGINNING_OR_END_UNDERSCORE_PATTERN, "")
    [field, value_with_no_special_chars].join("_").to_sym
  end
end
