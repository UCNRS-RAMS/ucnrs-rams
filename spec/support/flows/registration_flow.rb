class RegistrationFlow
  def initialize(page)
    @page = page
  end

  def visit_sign_up_page
    page.visit("/users/sign_up")
  end

  def on_sign_up_page?
    page.has_css?("body.registrations.registrations-new")
  end

  def on_sign_in_page?
    page.has_css?("body.sessions.sessions-new")
  end

  def has_validation_errors_on_sign_up_page?
    page.has_css?("body.registrations.registrations-create")
  end

  def fill_out_account_creation_form(
    first_name: "",
    last_name: "",
    phone_number: "",
    gender_identity: "Male",
    email: "",
    password: "",
    password_confirmation: "",
    age_range: "25-50",
    secondary_phone_number: "",
    accessibility_requirements: "",
    backup_email_address: "",
    role: "No selection",
    orcid: "",
    advisor: "",
    emergency_contact_full_name: "",
    emergency_contact_phone_number: "",
    address_line_1: "",
    address_line_2: "",
    address_city: "",
    address_postal_code: "",
    billing_address_same_as_current: "0",
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
    page.fill_in("ORCID (Optional)", with: orcid)
    page.fill_in("Advisor/Supervisor Name", with: advisor)
    page.fill_in("Full Name", with: emergency_contact_full_name)
    page.fill_in("Phone Number", id: "user_emergency_contact_phone_number", with: emergency_contact_phone_number)
    page.fill_in("Address", id: "user_address_line_1", with: address_line_1)
    page.fill_in("user_address_line_2", with: address_line_2)
    page.fill_in("City", id: "user_address_city", with: address_city)
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

  def submit_account_creation_form
    page.find("input[type='submit']").click
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

  private

  attr_reader :page
end
