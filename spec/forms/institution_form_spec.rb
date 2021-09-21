require "rails_helper"

RSpec.describe InstitutionForm do
  describe "initializing an institution" do
    it "inititalizes a new institution from params" do
      new_institution_params = {
        name: "University",
        city: "a city",
        institution_type: "university_of_california",
        state_id: 1,
        country_id: 2,
      }
      form = InstitutionForm.new(new_institution_params)

      expect(form.institution).to have_attributes(
        name: "University",
        city: "a city",
        institution_type: "university_of_california",
        state_id: 1,
        country_id: 2,
      )
    end
  end

  describe "#submit" do
    it "is false when passed invalid params" do
      invalid_institution_params = {
        name: "Institution",
      }

      form = InstitutionForm.new(invalid_institution_params)

      expect(form.submit).to be_falsey
    end

    it "creates saves and successfully creates a new institution when passed valid params" do
      country = create(:country)
      state = create(:state, country: country)
      valid_params = {
        name: "University of Fake",
        institution_type: "university_of_california",
        city: "a city",
        country_id: country.id,
        state_id: state.id,
      }

      form = InstitutionForm.new(valid_params)

      expect(form.submit).to be true
      expect(form.institution).to be_persisted
    end
  end
end