# frozen_string_literal: true

united_states = Country.coded("US")
california = State.coded("CA")

university = DevelopmentSeeds.record(
  Institution,
  { name: "Totally a Real University", city: "Real Place" },
  state: State.coded("MA"),
  country: united_states,
  institution_type: :non_california_us_university_or_college,
)

field_institute = DevelopmentSeeds.record(
  Institution,
  { name: "Example Field Research Institute", city: "Oakland" },
  state: california,
  country: united_states,
  institution_type: :non_governmental_organization_or_entity,
)

common_attributes = {
  address_line_1: "213 Main St.",
  address_city: "Example City",
  address_postal_code: "00001",
  address_state: california,
  address_country: united_states,
  phone_number: "111-222-3333",
  emergency_contact_full_name: "Example Emergency Contact",
  emergency_contact_phone_number: "111-222-3333",
  terms_accepted_at: Time.current,
  orcid_authenticated: false,
}

[
  ["mister@moustache.test", "Mister", "Moustache", :faculty, university, "0000-0002-1825-0097"],
  ["river@researcher.test", "River", "Researcher", :research_scientist, university, nil],
  ["sage@scientist.test", "Sage", "Scientist", :graduate_student, field_institute, "0000-0001-5109-3700"],
  ["manager@single-tree.test", "Morgan", "Manager", :reserve_staff, field_institute, nil],
].each do |email, first_name, last_name, role, institution, orcid|
  user = DevelopmentSeeds.record(
    User,
    { email: email },
    common_attributes.merge(
      first_name: first_name,
      last_name: last_name,
      role: role,
      institution: institution,
      orcid: orcid,
    ),
  ) { |record| record.password = "Password1" }
  user.confirm unless user.confirmed?
end
