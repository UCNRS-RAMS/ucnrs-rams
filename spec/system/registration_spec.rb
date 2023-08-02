require "rails_helper"

RSpec.describe "Registration" do
  describe "creating an account" do
    it "allows the user to view a form and create their account", js: true do
      country = create(:country, name: "United States")
      state = create(:state, country: country)
      institution = create(:institution, name: "University of California", country: country, state: state)

      flow = RegistrationFlow.new(page)

      flow.visit_sign_up_page
      expect(flow).to be_on_sign_up_page
      expect(page).to be_axe_clean.skipping(:"color-contrast")

      flow.fill_out_account_creation_form(
        first_name: "",
        last_name: "",
        password: "foo",
        emergency_contact_full_name: "",
        emergency_contact_phone_number: "",
        address_line_1: "",
        address_city: "",
        address_postal_code: "",
        institution: "",
      )
      flow.submit_account_creation_form
      expect(flow).to have_validation_errors_on_sign_up_page
      expect(page).to be_axe_clean.skipping(:"color-contrast")
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
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_institution")

      flow.fill_out_account_creation_form(
        first_name: "John",
        last_name: "Muir",
        password: "Password1",
        password_confirmation: "Password1",
        secondary_phone_number: "",
        backup_email_address: "",
        role: "Docent",
        orcid: "",
        advisor: "",
        institution: "University of California",
        emergency_contact_full_name: "Louisa Wanda Strentzel",
        emergency_contact_phone_number: "(222) 222 - 2222",
        address_line_1: "1 Muir Woods Rd",
        address_city: "Mill Valley",
        address_postal_code: "94941",
        address_country: country.name,
        address_state: state.name,
      )
      flow.select_billing_state

      flow.submit_account_creation_form
      expect(flow).to be_on_sign_in_page
      expect(page).to be_axe_clean.skipping(:"color-contrast")
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
      expect(page).to be_axe_clean.skipping(:"color-contrast")
      expect(flow).to have_displayed_institution("University of California")
      expect(flow).to have_displayed_institution("California Institute of Technology")

      flow.select_institution("University of California")
      expect(flow).to have_institution_field_with_value("University of California")
      expect(flow).to have_no_displayed_institutions
      expect(page).to be_axe_clean.skipping(:"color-contrast")
    end

    it "allows a user to dynamically select states based on the selected country", js: true do
      us = create(:country, name: "United States")
      create(:state, name: "California", country: us)
      create(:state, name: "Massachusetts", country: us)
      uk = create(:country, name: "United Kingdom")
      create(:state, name: "Avon", country: uk)
      create(:state, name: "Yorkshire", country: uk)
      create(:country, name: "Zimbabwe", states: [])
      flow = RegistrationFlow.new(page)

      flow.visit_sign_up_page
      expect(flow).to be_on_sign_up_page
      expect(flow).to have_selected_country_option_for(select_field: "user_address_country_id", country_name: "United States")
      expect(flow).to have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United States")
      expect(flow).to_not have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United Kingdom")

      flow.change_country_to(country_name: "United Kingdom", select_field: "user_address_country_id")
      expect(flow).to have_selected_country_option_for(select_field: "user_address_country_id", country_name: "United Kingdom")
      expect(flow).to have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United Kingdom")
      expect(flow).to_not have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United States")
      expect(page).to be_axe_clean

      expect(flow).to have_selected_country_option_for(select_field: "user_billing_address_country_id", country_name: "United States")
      expect(flow).to have_no_selected_option_for("user_billing_address_state_id")
      expect(page).to be_axe_clean.skipping(:"color-contrast")

      flow.change_country_to(country_name: "Zimbabwe", select_field: "user_billing_address_country_id")
      expect(flow).to have_selected_country_option_for(select_field: "user_billing_address_country_id", country_name: "Zimbabwe")
      expect(flow).to have_correct_state_options_for(select_field: "user_billing_address_state_id", country_name: "Zimbabwe")
      expect(page).to be_axe_clean.skipping(:"color-contrast")
    end

    it "toggles the billing address section based on whether the same_as_current checkbox is checked", js: true do
      us = create(:country, name: "United States")
      create(:state, name: "California", country: us)
      create(:state, name: "Massachusetts", country: us)
      uk = create(:country, name: "United Kingdom")
      create(:state, name: "Avon", country: uk)
      create(:state, name: "Yorkshire", country: uk)
      create(:country, name: "Zimbabwe", states: [])
      flow = RegistrationFlow.new(page)

      flow.visit_sign_up_page

      expect(flow).to be_showing_billing_address
      flow.click_checkbox
      expect(flow).not_to be_showing_billing_address
      flow.click_checkbox
      expect(flow).to be_showing_billing_address
    end
  end

  describe "editing an account" do
    it "allows the user to vew a form and edit their account", js: true do
      country = create(:country, name: "United States")
      state = create(:state, country: country)
      institution = create(:institution, name: "University of California", country: country, state: state)
      user = create(:user, :confirmed, institution: institution, address_country: country, address_state: state)

      flow = RegistrationFlow.new(page)
      sign_in(user)

      flow.visit_account_edit_page
      expect(flow).to be_on_account_edit_page
      expect(page).to be_axe_clean

      flow.fill_out_account_edit_form(
        first_name: "",
        last_name: "",
        emergency_contact_full_name: "",
        emergency_contact_phone_number: "",
        address_line_1: "",
        address_city: "",
        address_postal_code: "",
        institution: "",
      )
      flow.submit_account_edit_form
      expect(page).to be_axe_clean
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_first_name")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_last_name")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_institution")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_emergency_contact_full_name")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_emergency_contact_phone_number")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_address_line_1")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_address_city")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_address_postal_code")
      expect(flow).to have_form_error("can't be blank", on_field_with_id: "user_institution")

      flow.fill_out_account_edit_form(
        first_name: "John",
        last_name: "Muir",
        secondary_phone_number: "",
        backup_email_address: "",
        role: "Docent",
        orcid: "",
        advisor: "",
        institution: "University of California",
        emergency_contact_full_name: "Louisa Wanda Strentzel",
        emergency_contact_phone_number: "(222) 222 - 2222",
        address_line_1: "1 Muir Woods Rd",
        address_city: "Mill Valley",
        address_postal_code: "94941",
        address_country: country.name,
        address_state: state.name,
      )
      flow.submit_account_edit_form
      expect(flow).to be_on_account_update_page
      expect(page).to be_axe_clean
      expect(flow).to have_no_form_errors
    end

    it "allows users to search for an institution by name", js: true do
      user = create(:user, :confirmed)
      uc = create(:institution, name: "University of California")
      umass = create(:institution, name: "University of Massachusetts")
      caltech = create(:institution, name: "California Institute of Technology")

      flow = RegistrationFlow.new(page)
      sign_in(user)

      flow.visit_account_edit_page
      expect(flow).to be_on_account_edit_page

      flow.fill_out_institution_field("Cal")
      expect(flow).to have_displayed_institution("University of California")
      expect(flow).to have_displayed_institution("California Institute of Technology")

      flow.select_institution("University of California")
      expect(flow).to have_institution_field_with_value("University of California")
      expect(flow).to have_no_displayed_institutions
    end

    it "allows a user to dynamically select states based on the selected country", js: true do
      user = create(:user, :confirmed)
      us = create(:country, name: "United States")
      create(:state, name: "California", country: us)
      create(:state, name: "Massachusetts", country: us)
      uk = create(:country, name: "United Kingdom")
      create(:state, name: "Avon", country: uk)
      create(:state, name: "Yorkshire", country: uk)
      create(:country, name: "Zimbabwe", states: [])

      flow = RegistrationFlow.new(page)
      sign_in(user)

      flow.visit_account_edit_page
      expect(flow).to be_on_account_edit_page
      expect(flow).to have_selected_country_option_for(select_field: "user_address_country_id", country_name: "United States")
      expect(flow).to have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United States")
      expect(flow).to_not have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United Kingdom")

      flow.change_country_to(country_name: "United Kingdom", select_field: "user_address_country_id")
      expect(flow).to have_selected_country_option_for(select_field: "user_address_country_id", country_name: "United Kingdom")
      expect(flow).to have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United Kingdom")
      expect(flow).to_not have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United States")
      expect(page).to be_axe_clean

      expect(flow).to have_no_selected_option_for("user_billing_address_country_id")
      expect(flow).to have_no_selected_option_for("user_billing_address_state_id")
      expect(page).to be_axe_clean

      flow.change_country_to(country_name: "Zimbabwe", select_field: "user_billing_address_country_id")
      expect(flow).to have_selected_country_option_for(select_field: "user_billing_address_country_id", country_name: "Zimbabwe")
      expect(flow).to have_correct_state_options_for(select_field: "user_billing_address_state_id", country_name: "Zimbabwe")
      expect(page).to be_axe_clean
    end

    it "toggles the billing address section based on whether the same_as_current checkbox is checked", js: true do
      user = create(:user, :confirmed)
      us = create(:country, name: "United States")
      create(:state, name: "California", country: us)
      create(:state, name: "Massachusetts", country: us)
      uk = create(:country, name: "United Kingdom")
      create(:state, name: "Avon", country: uk)
      create(:state, name: "Yorkshire", country: uk)
      create(:country, name: "Zimbabwe", states: [])
      flow = RegistrationFlow.new(page)
      sign_in(user)

      flow.visit_account_edit_page

      expect(flow).to be_showing_billing_address
      flow.click_checkbox
      expect(flow).not_to be_showing_billing_address
      flow.click_checkbox
      expect(flow).to be_showing_billing_address
    end
  end
end
