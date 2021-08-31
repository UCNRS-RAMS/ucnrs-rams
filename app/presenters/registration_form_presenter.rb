class RegistrationFormPresenter
  SPECIAL_CHARACTERS_PATTERN = %r{[^0-9A-Za-z]+}
  BEGINNING_OR_END_UNDERSCORE_PATTERN = %r{(?:\A_+|_+\z)}

  attr_reader :user

  def initialize
    @user = User.new
  end

  def gender_identity_options
    ["--Select--", "Male", "Female", "Non-binary"]
  end

  def age_range_options
    ["1-17", "18-25", "25-50", "50 or older"]
  end

  def phone_number_placeholder
    I18n.t(".devise.registrations.new.placeholders.phone_number")
  end

  def role_options
    [
      "No selection",
      "Faculty",
      "Research Scientist/Post Doc",
      "Research Assistant (non-student/faculty/postdoc)",
      "Graduate Student",
      "Undergraduate Student",
      "K-12 Instructor",
      "K-12 Student",
      "Professional",
      "Other",
      "Docent",
      "Volunteer",
      "Staff",
    ]
  end

  def country_options
    ["United States", "Canada"]
  end

  def state_options
    %w[Massachusetts Quebec]
  end

  def identifier_for(field, value)
    value_with_no_special_chars = value
      .downcase
      .gsub(SPECIAL_CHARACTERS_PATTERN, "_")
      .gsub(BEGINNING_OR_END_UNDERSCORE_PATTERN, "")
    [field, value_with_no_special_chars].join("_").to_sym
  end
end
