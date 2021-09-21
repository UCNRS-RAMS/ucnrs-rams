require "rails_helper"

RSpec.describe InstitutionFormPresenter do
  describe "#form_institution" do
    it "is the form's institution" do
      form = InstitutionForm.new
      presenter = InstitutionFormPresenter.new(form)

      expect(presenter.form_institution).to eq(form.institution)
    end
  end

  describe "#institution_type_options" do
    it "is an array of institution type options" do
      presenter = InstitutionFormPresenter.new

      institution_type_options = presenter.institution_type_options

      expect(institution_type_options).to match_array [
        ["University of California", "university_of_california"],
        ["California State University System", "california_state_university_system"],
        ["California Community College", "california_community_college"],
        ["California - Other University or College", "other_california_university_or_college"],
        ["U.S. - University or College Outside of California", "non_california_us_university_or_college"],
        ["International University or College", "international_university_or_college"],
        ["K-12 Education", "k_12_education"],
        ["Non-Governmental Organization or Non-Profit Entity", "non_governmental_organization_or_entity"],
        ["Governmental Agency or Entity", "governmental_organization_or_entity"],
        ["Business Entity", "business_entity"],
        ["Individual or Other Entity", "individual_or_other_entity"],
      ]
    end
  end

end
