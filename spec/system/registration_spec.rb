require "rails_helper"

RSpec.describe "Registration" do
  describe "creating an account" do
    it "allows the user to view a form and create their account", js: true do
      institution = create(:institution, name: "University of California")
      country = create(:country, name: "United States")
      state = create(:state, country: country)

      flow = RegistrationFlow.new(page)

      flow.visit_sign_up_page
      expect(flow).to be_on_sign_up_page
      expect(page).to be_axe_clean

      flow.fill_out_account_creation_form(email: "john@muir.test", password: "foo")
      flow.submit_account_creation_form
      expect(flow).to have_validation_errors_on_sign_up_page
      expect(page).to be_axe_clean
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_first_name")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_last_name")
      expect(flow).to have_form_error(
        "Password complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase character and 1 digit.",
        on_field_with_id: "user_password",
      )
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_institution")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_emergency_contact_full_name")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_emergency_contact_phone_number")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_address_line_1")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_address_city")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_address_postal_code")

      flow.fill_out_account_creation_form(
        first_name: "John",
        last_name: "Muir",
        phone_number: "(111) 111 - 1111",
        gender_identity: "Male",
        email: "john@muirwoods.test",
        password: "Password1",
        password_confirmation: "Password1",
        age_range: "50 or older",
        secondary_phone_number: "",
        accessibility_requirements: "",
        backup_email_address: "",
        role: "Docent",
        orcid: "",
        advisor: "",
        institution: "University of California",
        emergency_contact_full_name: "Louisa Wanda Strentzel",
        emergency_contact_phone_number: "(222) 222 - 2222",
        address_line_1: "1 Muir Woods Road",
        address_line_2: "",
        address_city: "Mill Valley",
        address_postal_code: "94941",
        billing_address_same_as_current: "1",
        billing_address_line_1: "",
        billing_address_line_2: "",
        billing_address_city: "",
        billing_address_postal_code: "",
        billing_person_full_name: "",
        billing_person_email: "",
        billing_person_phone_number: ""
      )
      flow.submit_account_creation_form
      expect(flow).to be_on_sign_in_page
      expect(page).to be_axe_clean
      expect(flow).to have_no_form_errors
    end

    it "allows users to search for an institution by name", js: true do
      uc = create(:institution, name: "University of California")
      umass = create(:institution, name: "University of Massachusetts")
      caltech = create(:institution, name: "California Institute of Technology")

      flow = RegistrationFlow.new(page)

      flow.visit_sign_up_page
      expect(flow).to be_on_sign_up_page

      flow.fill_out_institution_field("Cal")
      expect(page).to be_axe_clean
      expect(flow).to have_displayed_institution("University of California")
      expect(flow).to have_displayed_institution("California Institute of Technology")

      flow.select_institution("University of California")
      expect(flow).to have_institution_field_with_value("University of California")
      expect(flow).to have_no_displayed_institutions
      expect(page).to be_axe_clean
    end
  end
end
