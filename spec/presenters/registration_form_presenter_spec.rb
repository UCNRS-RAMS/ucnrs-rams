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

  describe "#age_range_options" do
    it "is an array of age range options" do
      presenter = RegistrationFormPresenter.new

      age_range_options = presenter.age_range_options

      expect(age_range_options).to match_array [
        ["1-17", :age_range_1_17],
        ["18-25", :age_range_18_25],
        ["25-50", :age_range_25_50],
        ["50 or older", :age_range_50_or_older],
      ]
    end
  end

  describe "#role_options" do
    it "is an array of role options" do
      presenter = RegistrationFormPresenter.new

      role_options = presenter.role_options

      expect(role_options).to match_array [
        ["No selection", :role_no_selection],
        ["Faculty", :role_faculty],
        ["Research Scientist/Post Doc", :role_research_scientist_post_doc],
        ["Research Assistant (non-student/faculty/postdoc)", :role_research_assistant_non_student_faculty_postdoc],
        ["Graduate Student", :role_graduate_student],
        ["Undergraduate Student", :role_undergraduate_student],
        ["K-12 Instructor", :role_k_12_instructor],
        ["K-12 Student", :role_k_12_student],
        ["Professional", :role_professional],
        ["Other", :role_other],
        ["Docent", :role_docent],
        ["Volunteer", :role_volunteer],
        ["Staff", :role_staff],
      ]
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

  describe "#initial_state_options" do
    it "returns an array of U.S. states alphabetized by name" do
      us = create(:country)
      canada = create(:country)
      massachusetts = create(:state, name: "Massachusetts", country: us)
      california = create(:state, name: "California", country: us)
      non_us_state = create(:state, name: "Quebec", country: canada)
      presenter = RegistrationFormPresenter.new
  
      expect(presenter.initial_state_options).to contain_exactly california, massachusetts
    end
  end

  describe "#default_gender_identity_option" do
    it "is an array containing the value and key for the 'Prefer not to state' enum option" do
      presenter = RegistrationFormPresenter.new

      expect(presenter.default_gender_identity_option).to match_array ["Prefer not to state", :prefer_not_to_state]
    end
  end
end
