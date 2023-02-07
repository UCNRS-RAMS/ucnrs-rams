require "rails_helper"

RSpec.describe RegistrationFormPresenter do
  describe "#form_user" do
    it "is the form's user" do
      form = RegistrationForm.new
      presenter = RegistrationFormPresenter.new(form)

      expect(presenter.form_user).to eq(form.user)
    end
  end

  describe "#gender_identity_options" do
    it "is an array of gender identity options" do
      presenter = RegistrationFormPresenter.new

      gender_identity_options = presenter.gender_identity_options

      expect(gender_identity_options).to match_array [
        ["Male", "male"],
        ["Female", "female"],
        ["Non-binary", "non_binary"],
        ["Other", "other_gender"],
        ["Prefer not to state", "prefer_not_to_state"],
      ]
    end
  end

  describe "#change_password" do
    it "return password index path" do
      presenter = RegistrationFormPresenter.new

      output = "<a rel=\"nofollow\" data-method=\"post\" href=\"/password\">Change Password</a>"

      expect(presenter.change_password).to eq output
    end
  end

  describe "#age_range_options" do
    it "is an array of age range options" do
      presenter = RegistrationFormPresenter.new

      age_range_options = presenter.age_range_options

      expect(age_range_options).to match_array [
        ["one_to_seventeen", "1-17"],
        ["eighteen_to_twenty_five", "18-25"],
        ["twenty_five_to_fifty", "25-50"],
        ["fifty_or_older", "50 or older"],
      ]
    end
  end

  describe "#role_options" do
    it "is an array of role options" do
      presenter = RegistrationFormPresenter.new

      role_options = presenter.role_options

      expect(role_options).to match_array [
        ["Faculty", "faculty"],
        ["Research Scientist/Post Doc", "research_scientist"],
        ["Research Assistant (non-student/faculty/postdoc)", "research_assistant"],
        ["Graduate Student", "graduate_student"],
        ["Undergraduate Student", "undergraduate_student"],
        ["K-12 Instructor", "k_12_instructor"],
        ["K-12 Student", "k_12_student"],
        ["Professional", "professional"],
        ["Other", "other"],
        ["Docent", "docent"],
        ["Volunteer", "volunteer"],
        ["Reserve Staff", "reserve_staff"],
      ]
    end
  end

  describe "#role_with_allowed_advisor_options" do
    it "it return an array of role_with_allowed_advisor_options" do
      presenter = RegistrationFormPresenter.new

      result = [
        "research_scientist",
        "research_assistant",
        "graduate_student",
        "undergraduate_student"
      ]

      expect(presenter.role_with_allowed_advisor_options).to eq result
    end
  end

  describe "#phone_number_placeholder" do
    it "is the placeholder for telephone fields" do
      presenter = RegistrationFormPresenter.new

      expect(presenter.phone_number_placeholder).to eq "(_ _ _) _ _ _ - _ _ _ _"
    end
  end

  describe "#postal_code_placeholder" do
    it "is the placeholder for postal code fields" do
      presenter = RegistrationFormPresenter.new

      expect(presenter.postal_code_placeholder).to eq "_ _ _ _ _"
    end
  end

  describe "#default_country_option" do
    it "is an array containing the name and id for the United States" do
      country = create(:country, name: "United States")
      presenter = RegistrationFormPresenter.new

      expect(presenter.default_country_option).to match_array ["United States", country.id]
    end
  end

  describe "#default_state_option" do
    it "is an array containing the name and id for California" do
      state = create(:state, name: "California")
      presenter = RegistrationFormPresenter.new

      expect(presenter.default_state_option).to match_array ["California", state.id]
    end
  end

  describe "#address_state_options" do
    it "returns an array of U.S. states alphabetized by name if form country id is empty" do
      us = create(:country)
      canada = create(:country)
      massachusetts = create(:state, name: "Massachusetts", country: us)
      california = create(:state, name: "California", country: us)
      non_us_state = create(:state, name: "Quebec", country: canada)
      presenter = RegistrationFormPresenter.new
  
      expect(presenter.address_state_options).to eq [california, massachusetts]
    end

    it "returns an array of states alphabetized by name based on the form address country" do
      us = create(:country)
      canada = create(:country)
      massachusetts = create(:state, name: "Massachusetts", country: us)
      california = create(:state, name: "California", country: us)
      non_us_state = create(:state, name: "Quebec", country: canada)

      form = RegistrationForm.new(params: { address_country_id: canada.id })
      presenter = RegistrationFormPresenter.new(form)
  
      expect(presenter.address_state_options).to eq [non_us_state]
    end
  end

  describe "#billing_address_state_options" do
    it "returns an array of states alphabetized by name based on the form billing address country" do
      us = create(:country)
      canada = create(:country)
      massachusetts = create(:state, name: "Massachusetts", country: us)
      california = create(:state, name: "California", country: us)
      non_us_state = create(:state, name: "Quebec", country: canada)

      form = RegistrationForm.new(params: { billing_address_country_id: us.id })
      presenter = RegistrationFormPresenter.new(form)
  
      expect(presenter.address_state_options).to eq [california, massachusetts]
    end
  end

  describe "#default_gender_identity_option" do
    it "is an array containing the value and key for the 'Prefer not to state' enum option" do
      presenter = RegistrationFormPresenter.new

      expect(presenter.default_gender_identity_option).to match_array ["Prefer not to state", :prefer_not_to_state]
    end
  end
end
