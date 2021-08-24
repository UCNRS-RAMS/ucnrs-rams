require "rails_helper"

RSpec.describe Unauthenticated::CreateAccountFormComponent, type: :component do
  it "renders the 'Basics' section of the CreateAccountFormComponent" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_css("legend", text: "Basics")
    expect(rendered_component).to have_select(
      "Gender Identity",
      options: ["--Select--", "Male", "Female", "Non-binary"],
      )
    expect(rendered_component).to have_field("First Name", type: "text")
    expect(rendered_component).to have_field("Last Name", type: "text")
    expect(rendered_component).to have_css("legend", text: "Age Range (Optional)")
    expect(rendered_component).to have_css("p", text: "This helps with demographic reporting")
    expect(rendered_component).to have_field("age_range_1-17", type: "radio")
    expect(rendered_component).to have_field("age_range_18-25", type: "radio")
    expect(rendered_component).to have_field("age_range_25-50", type: "radio")
    expect(rendered_component).to have_field("age_range_50_or_older", type: "radio")
    expect(rendered_component).to have_field("Phone Number", type: "text")
    expect(rendered_component).to have_field("Secondary Phone Number (Optional)", type: "text")
    expect(rendered_component).to have_field(
      "Accessibility Requirements or Known Allergies (Optional)",
      type: "textarea",
    )
    expect(rendered_component).to have_field("Email Address", type: "text")
    expect(rendered_component).to have_field("Backup Email Address", type: "text")
    expect(rendered_component).to have_field("Password", type: "password")
    expect(rendered_component).to have_css(
      "p",
      text: "Passwords should be 8 or more characters in length, use at least 1 upper-case character, and include at least 1 numerical digit.",
    )
    expect(rendered_component).to have_field("Re-Enter Password", type: "password")
  end

  it "renders the 'Role' section of the CreateAccountFormComponent" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_css("legend", text: "Role")
    expect(rendered_component).to have_field("role_no_selection", type: "radio")
    expect(rendered_component).to have_field("role_faculty", type: "radio")
    expect(rendered_component).to have_field("role_research_scientistpost_doc", type: "radio")
    expect(rendered_component).to have_field(
      "role_research_assistant_non-studentfacultypostdoc",
      type: "radio",
    )
    expect(rendered_component).to have_field("role_graduate_student", type: "radio")
    expect(rendered_component).to have_field("role_undergraduate_student", type: "radio")
    expect(rendered_component).to have_field("role_k-12_instructor", type: "radio")
    expect(rendered_component).to have_field("role_k-12_student", type: "radio")
    expect(rendered_component).to have_field("role_professional", type: "radio")
    expect(rendered_component).to have_field("role_other", type: "radio")
    expect(rendered_component).to have_field("role_docent", type: "radio")
    expect(rendered_component).to have_field("role_volunteer", type: "radio")
    expect(rendered_component).to have_field("role_staff", type: "radio")
    expect(rendered_component).to have_field(
      "Institution, Organization, or Agency",
      type: "text",
    )
    expect(rendered_component).to have_content(
      "TIP: Your institution is likely already in our database. Start typing to search. If you cannot find your institution,"
    )
    expect(rendered_component).to have_link("Create a New Institution")
    expect(rendered_component).to have_field("Advisor/Supervisor Name", type: "text")
    expect(rendered_component).to have_field("ORCID (Optional)", type: "text")
    expect(rendered_component).to have_link("What is an ORCID?")
  end

  it "renders the 'Emergency Contact' section of the CreateAccountFormComponent" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_css("legend", text: "Emergency Contact")
    expect(rendered_component).to have_content(
      "In case we need to notify someone while you’re at the reserve."
    )
    expect(rendered_component).to have_field("Full Name", type: "text")
    expect(rendered_component).to have_field("Phone Number", type: "text")
  end

  it "renders the 'Current Address' section of the CreateAccountFormComponent" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_css("legend", text: "Current Address")
    expect(rendered_component).to have_select(
      "address_country",
      options: ["United States", "Canada"],
      selected: "United States",
    )
    expect(rendered_component).to have_field("address_line_1", type: "text")
    expect(rendered_component).to have_field("address_line_2", type: "text")
    expect(rendered_component).to have_field("address_city", type: "text")
    expect(rendered_component).to have_select("address_state", options: %w[Massachusetts Quebec])
    expect(rendered_component).to have_field("address_postal_code", type: "text")
  end

  it "renders the 'Billing Address' section of the CreateAccountFormComponent" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_css("legend", text: "Billing Address")
    expect(rendered_component).to have_field("billing_address_same_as_current", type: "checkbox")
    expect(rendered_component).to have_select(
      "billing_address_country",
      options: ["United States", "Canada"],
      selected: "United States",
    )
    expect(rendered_component).to have_field("billing_address_address_line_1", type: "text")
    expect(rendered_component).to have_field("billing_address_address_line_2", type: "text")
    expect(rendered_component).to have_field("billing_address_city", type: "text")
    expect(rendered_component).to have_select(
      "billing_address_state",
      options: %w[Massachusetts Quebec],
    )
    expect(rendered_component).to have_field("billing_address_postal_code", type: "text")
    expect(rendered_component).to have_field("billing_person_full_name", type: "text")
    expect(rendered_component).to have_field("billing_person_email", type: "text")
    expect(rendered_component).to have_field("billing_person_phone_number", type: "text")
  end

  it "renders helper text and a link to sign up for the UCNRS newsletter" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_css(
      "p",
      text: "If you would like to receive updates from the NRS please sign up for the",
    )
    expect(rendered_component).to have_link("NRS Newsletter.")
  end

  it "renders an unchecked checkbox for Terms of Use acceptance" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_field(
      "I agree to the Terms of Use of the UC RAMS website.",
      type: "checkbox",
      checked: false,
    )
    expect(rendered_component).to have_link("Terms of Use")
  end

  it "renders a link to go back" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_link("Cancel, Go Back")
  end

  it "renders a button to submit the form" do
    component = Unauthenticated::CreateAccountFormComponent.new

    render_inline(component)

    expect(rendered_component).to have_button("Create Account -->")
  end
end
