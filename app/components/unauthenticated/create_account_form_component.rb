module Unauthenticated
  class CreateAccountFormComponent < ViewComponent::Base
    CreateAccountForm = Struct.new(:user)

    attr_reader :form_object

    def initialize(user: nil)
      @user = user
      @form_object = CreateAccountForm.new(@user)
    end

    def gender_identity_options
      ["--Select--", "Male", "Female", "Non-binary"]
    end

    def age_range_options
      ["1-17", "18-25", "25-50", "50 or older"]
    end

    def phone_number_placeholder
      I18n.t(".users.new.placeholders.phone_number")
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
  end
end
