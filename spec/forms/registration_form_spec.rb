require "rails_helper"

RSpec.describe RegistrationForm do
  describe "#errors" do
    it "is the user's errors" do
      new_user_params = { first_name: "" }
      form = RegistrationForm.new(new_user_params)

      form.submit

      error_messages = form.errors.messages
      expect(error_messages[:first_name]).to include("can't be blank")
    end
  end

  describe "initializing a user" do
    it "inititalizes a new user from params" do
      new_user_params = {
        gender_identity: "Male",
        first_name: "John",
        last_name: "Muir",
      }
      form = RegistrationForm.new(new_user_params)

      expect(form.user).to have_attributes(
        gender_identity: "male",
        first_name: "John",
        last_name: "Muir",
      )
    end

    it "fills in the billing address fields if the billing address is the same as the current address" do
      country = create(:country)
      state = create(:state, country: country)

      new_user_params = {
        address_line_1: "1 Muir Woods Road",
        address_city: "Mill Valley",
        address_country_id: country.id,
        address_state_id: state.id,
        address_postal_code: "94941",
        billing_address_same_as_current: "1",
      }
      form = RegistrationForm.new(new_user_params)

      expect(form.user).to have_attributes(
        billing_address_line_1: "1 Muir Woods Road",
        billing_address_city: "Mill Valley",
        billing_address_country_id: country.id,
        billing_address_state_id: state.id,
        billing_address_postal_code: "94941",
        billing_address_same_as_current: true,
      )
    end

    it "does not fill in the billing address fields if the billing address is not the same as the current address" do
      country = create(:country)
      state = create(:state, country: country)
      new_user_params = {
        address_line_1: "1 Muir Woods Road",
        address_city: "Mill Valley",
        address_country_id: country.id,
        address_state_id: state.id,
        address_postal_code: "94941",
        billing_address_same_as_current: "0",
      }
      form = RegistrationForm.new(new_user_params)

      expect(form.user).to have_attributes(
        billing_address_line_1: nil,
        billing_address_city: nil,
        billing_address_country_id: nil,
        billing_address_state_id: nil,
        billing_address_postal_code: nil,
        billing_address_same_as_current: false,
      )
    end

    it "assigns the current time to the user's terms_accepted_at" do
      new_user_params = {
        first_name: "John",
        last_name: "Muir",
        terms_accepted_at: "1",
      }

      freeze_time do
        form = RegistrationForm.new(new_user_params)

        expect(form.user).to have_attributes(terms_accepted_at: Time.current)
      end
    end

    it "assigns the user's institution_id from the instituion name in the params" do
      institution = create(:institution, name: "University of California")
      new_user_params = { institution: "University of California" }
      form = RegistrationForm.new(new_user_params)

      expect(form.user).to have_attributes(institution_id: institution.id)
    end
  end

  describe "#submit" do
    it "is false when passed invalid params" do
      invalid_user_params = {
        first_name: "John",
        last_name: "Muir",
      }

      form = RegistrationForm.new(invalid_user_params)

      expect(form.submit).to be_falsey
    end

    it "creates saves and successfully creates a new user when passed valid params" do
      country = create(:country)
      state = create(:state, country: country)
      institution = create(:institution, name: "University of California")
      valid_params = {
        first_name: "John",
        last_name: "Muir",
        address_line_1: "1 Muir Woods Road",
        address_city: "Mill Valley",
        address_country_id: country.id,
        address_state_id: state.id,
        address_postal_code: "94941",
        email: "john@muirwoods.test",
        phone_number: "(222) 222-2222",
        emergency_contact_full_name: "Louisa Wanda Strentzel",
        emergency_contact_phone_number: "(111) 111-1111",
        institution: institution.name,
        role: "Docent",
        billing_address_same_as_current: "1",
        password: "Password1",
        password_confirmation: "Password1",
        terms_accepted_at: "1",
      }

      form = RegistrationForm.new(valid_params)

      expect(form.submit).to be true
      expect(form.user).to be_persisted
    end
  end
end
