class RegistrationFlow
  def initialize(page)
    @page = page
  end

  def visit_sign_up_page
    page.visit("/users/sign_up")
  end

  def visit_account_edit_page
    page.visit("/users/edit")
  end

  def on_sign_up_page?
    page.has_css?("body.registrations.registrations-new")
  end

  def on_sign_in_page?
    page.has_css?("body.sessions.sessions-new")
  end

  def on_account_edit_page?
    page.has_css?("body.registrations.registrations-edit")
  end

  def on_account_update_page?
    page.has_css?("body.registrations.registrations-update")
  end

  def has_validation_errors_on_sign_up_page?
    page.has_css?("body.registrations.registrations-create")
  end

  def fill_out_account_creation_form(
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
    institution: "",
    emergency_contact_full_name: "Louisa Wanda Strentzel",
    emergency_contact_phone_number: "(222) 222 - 2222",
    address_line_1: "1 Muir Woods Road",
    address_line_2: "",
    address_city: "Mill Valley",
    address_postal_code: "94941",
    address_country: "United States",
    address_state: "California",
    billing_address_same_as_current: "1",
    billing_address_line_1: "",
    billing_address_line_2: "",
    billing_address_city: "",
    billing_address_postal_code: "",
    billing_person_full_name: "",
    billing_person_email: "",
    billing_person_phone_number: ""
  )
    page.fill_in("First Name", with: first_name)
    page.fill_in("Last Name", with: last_name)
    page.fill_in("Phone Number", id: "user_phone_number", with: phone_number)
    page.select(gender_identity, from: "Gender Identity")
    page.fill_in("Email", id: "user_email", with: email)
    page.fill_in("Password", id: "user_password", with: password)
    page.fill_in("Re-Enter Password", id: "user_password_confirmation", with: password)
    page.choose(age_range)
    page.fill_in("Secondary Phone Number (Optional)", id: "user_secondary_phone_number", with: secondary_phone_number)
    page.fill_in("Accessibility Requirements or Known Allergies (Optional)", with: accessibility_requirements)
    page.fill_in("Backup Email Address", id: "user_backup_email_address", with: backup_email_address)
    page.choose(role)
    page.fill_in("Institution, Organization, or Agency", with: institution)
    page.fill_in("ORCID (Optional)", with: orcid)
    page.fill_in("Advisor/Supervisor Name", with: advisor)
    page.fill_in("Full Name", with: emergency_contact_full_name)
    page.fill_in("Phone Number", id: "user_emergency_contact_phone_number", with: emergency_contact_phone_number)
    page.fill_in("Address", id: "user_address_line_1", with: address_line_1)
    page.fill_in("user_address_line_2", with: address_line_2)
    page.fill_in("City", id: "user_address_city", with: address_city)
    page.select(address_country, from: "user_address_country_id")
    page.select(address_state, from: "user_address_state_id")
    page.fill_in("Zip/Postcode", id: "user_address_postal_code", with: address_postal_code)
    page.fill_in("Address", id: "user_billing_address_line_1", with: billing_address_line_1)
    page.fill_in("user_billing_address_line_2", with: billing_address_line_2)
    page.fill_in("City", id: "user_billing_address_city", with: billing_address_city)
    page.fill_in("Zip/Postcode", id: "user_billing_address_postal_code", with: billing_address_postal_code)
    page.fill_in("Billing Name (Optional)", with: billing_person_full_name)
    page.fill_in("Billing Email Address (Optional)", with: billing_person_email)
    page.fill_in("Billing Phone Number (Optional)", with: billing_person_phone_number)
    page.check("user_terms_accepted_at")
  end

  def fill_out_account_edit_form(
    first_name: "John",
    last_name: "Muir",
    phone_number: "(111) 111 - 1111",
    gender_identity: "Male",
    email: "john@muirwoods.test",
    age_range: "50 or older",
    secondary_phone_number: "",
    accessibility_requirements: "",
    backup_email_address: "",
    role: "Docent",
    orcid: "",
    advisor: "",
    institution: "",
    emergency_contact_full_name: "Louisa Wanda Strentzel",
    emergency_contact_phone_number: "(222) 222 - 2222",
    address_line_1: "1 Muir Woods Road",
    address_line_2: "",
    address_city: "Mill Valley",
    address_postal_code: "94941",
    address_country: "United States",
    address_state: "California",
    billing_address_same_as_current: "1",
    billing_address_line_1: "",
    billing_address_line_2: "",
    billing_address_city: "",
    billing_address_postal_code: "",
    billing_person_full_name: "",
    billing_person_email: "",
    billing_person_phone_number: ""
  )
    page.fill_in("First Name", with: first_name)
    page.fill_in("Last Name", with: last_name)
    page.fill_in("Phone Number", id: "user_phone_number", with: phone_number)
    page.select(gender_identity, from: "Gender Identity")
    page.fill_in("Email", id: "user_email", with: email)
    page.choose(age_range)
    page.fill_in("Secondary Phone Number (Optional)", id: "user_secondary_phone_number", with: secondary_phone_number)
    page.fill_in("Accessibility Requirements or Known Allergies (Optional)", with: accessibility_requirements)
    page.fill_in("Backup Email Address", id: "user_backup_email_address", with: backup_email_address)
    page.choose(role)
    page.fill_in("Institution, Organization, or Agency", with: institution)
    page.fill_in("ORCID (Optional)", with: orcid)
    page.fill_in("Advisor/Supervisor Name", with: advisor)
    page.fill_in("Full Name", with: emergency_contact_full_name)
    page.fill_in("Phone Number", id: "user_emergency_contact_phone_number", with: emergency_contact_phone_number)
    page.fill_in("Address", id: "user_address_line_1", with: address_line_1)
    page.fill_in("user_address_line_2", with: address_line_2)
    page.fill_in("City", id: "user_address_city", with: address_city)
    page.select(address_country, from: "user_address_country_id")
    page.select(address_state, from: "user_address_state_id")
    page.fill_in("Zip/Postcode", id: "user_address_postal_code", with: address_postal_code)
    page.fill_in("Address", id: "user_billing_address_line_1", with: billing_address_line_1)
    page.fill_in("user_billing_address_line_2", with: billing_address_line_2)
    page.fill_in("City", id: "user_billing_address_city", with: billing_address_city)
    page.fill_in("Zip/Postcode", id: "user_billing_address_postal_code", with: billing_address_postal_code)
    page.fill_in("Billing Name (Optional)", with: billing_person_full_name)
    page.fill_in("Billing Email Address (Optional)", with: billing_person_email)
    page.fill_in("Billing Phone Number (Optional)", with: billing_person_phone_number)
  end

  def submit_account_creation_form
    page.find("button[type='submit']").click
  end

  def submit_account_edit_form
    page.find("button[type='submit']").click
  end

  def has_form_error?(error, on_field_with_id:)
    page
      .find("label[for=\"#{on_field_with_id}\"]")
      .find(:xpath, "..")
      .has_selector?(".error_messages", text: error)
  end

  def has_no_form_errors?
    page.find_all(:css, ".error_messages").length == 0
  end

  def fill_out_institution_field(query)
    page.fill_in("Institution, Organization, or Agency", with: query, fill_options: { clear: :backspace })
  end

  def has_displayed_institution?(institution_name)
    page.has_selector?("li", text: institution_name)
  end

  def select_institution(institution_name)
    page.find("li", text: institution_name).click
  end

  def has_institution_field_with_value?(institution_name)
    page.has_field?("Institution, Organization, or Agency", with: institution_name)
  end

  def has_no_displayed_institutions?
    page.has_no_css?("div#institutions", text: "")
  end

  def has_selected_country_option_for?(select_field:, country_name:)
    page.has_select?(select_field, selected: country_name)
  end

  def has_no_selected_option_for?(select_field)
    page.has_select?(select_field, selected: "")
  end

  def has_correct_state_options_for?(select_field:, country_name:)
    state_names = Country.find_by(name: country_name)
      .states
      .order(:name)
      .pluck(:name) || []
    options = page.find("##{select_field}").all("option").collect(&:text)

    state_names == options.reject(&:empty?)
  end

  def change_country_to(select_field:, country_name:)
    page.select(country_name, from: select_field)
  end

  private

  attr_reader :page
end
