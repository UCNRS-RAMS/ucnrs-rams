# frozen_string_literal: true

principal_investigator = User.find_by!(email: "mister@moustache.test")
researcher = User.find_by!(email: "river@researcher.test")
graduate_student = User.find_by!(email: "sage@scientist.test")
a_single_tree = Reserve.find_by!(name: "A Single Tree")
oak_ridge = Reserve.find_by!(name: "Oak Ridge")

project_defaults = {
  status: :open,
  method_remove_organisms: false,
  method_transfer_organisms: false,
  method_study_non_native_species: false,
  method_chemicals: false,
  method_soil_disturbance: false,
  method_long_term_structures: false,
  involves_mammals: false,
  involves_reptiles: false,
  involves_amphibians: false,
  involves_fish: false,
  involves_birds: false,
  involves_plants_fungi_soil: true,
  involves_none: false,
  involves_threatened_endangered_species: false,
}

research_project = DevelopmentSeeds.record(
  Project,
  { title: "Long-term Forest Microclimate Study" },
  project_defaults.merge(
    reserve: a_single_tree,
    owner: principal_investigator,
    applicant: principal_investigator,
    project_type: :research,
    start_date: 5.years.ago.to_date,
    end_date: 1.year.ago.to_date,
    submitted_at: 5.years.ago,
    abstract: "A representative longitudinal study of forest microclimates.",
    discipline: "Environmental Science/Natural Resources",
    method_description: "Repeated field observations at established sampling locations.",
    method_study_area: "Forest plots surrounding the field station.",
    method_long_term_structures: true,
  ),
)

class_project = DevelopmentSeeds.record(
  Project,
  { title: "Field Methods in Oak Woodland Ecology" },
  project_defaults.merge(
    reserve: oak_ridge,
    owner: researcher,
    applicant: researcher,
    project_type: :class,
    start_date: 1.month.from_now.to_date,
    end_date: 2.months.from_now.to_date,
    course_title: "Field Ecology",
    course_number: "ECO 201",
    discipline: "Biology",
    method_description: "Non-destructive vegetation surveys and field observation.",
    method_study_area: "Oak woodland teaching plots.",
  ),
)

memberships = [
  [research_project, principal_investigator, true, true, true, true, true],
  [research_project, researcher, false, true, true, true, false],
  [research_project, graduate_student, false, false, false, true, false],
  [class_project, researcher, true, true, true, true, true],
  [class_project, graduate_student, false, false, false, true, false],
]

memberships.each do |project, user, principal, edit, add_user, add_visit, receive_invoice|
  DevelopmentSeeds.record(
    ProjectTeamMembership,
    { project: project, user: user },
    institution: user.institution,
    active: true,
    user_role: user.role,
    is_principal_investigator: principal,
    can_edit_project: edit,
    can_add_project_user: add_user,
    can_add_visit: add_visit,
    can_receive_invoice: receive_invoice,
  )
end

DevelopmentSeeds.record(
  Funding,
  { project: research_project, title: "Forest Microclimate Research Award" },
  reserve: a_single_tree,
  is_funded: true,
  is_submitted: true,
  will_be_submitted: false,
  was_denied: false,
  principal_investigators: principal_investigator.full_name,
  sponsor: :national_science_foundation,
  grant_number: "EXAMPLE-12345",
  funding_opportunity_number: "EXAMPLE-FON-2020",
  award_amount: 75_000,
  start_date: research_project.start_date,
  end_date: research_project.end_date,
)

visit_starts_at = 3.years.ago.change(month: 6, day: 12, hour: 9)
visit_ends_at = visit_starts_at + 3.days + 8.hours

research_visit = DevelopmentSeeds.record(
  Visit,
  { project: research_project, sign_token: "development-research-visit" },
  reserve: a_single_tree,
  user: principal_investigator,
  project_type: :research,
  status: :approved,
  submitted_at: visit_starts_at - 2.months,
  policy_agreement: true,
  purpose_of_visit: "Collect seasonal measurements from established forest plots.",
  start_date: visit_starts_at.to_date,
  end_date: visit_ends_at.to_date,
  start_time: visit_starts_at,
  end_time: visit_ends_at,
  starts_at: visit_starts_at,
  ends_at: visit_ends_at,
)

[principal_investigator, researcher, graduate_student].each do |participant|
  DevelopmentSeeds.record(
    UserVisit,
    { visit: research_visit, user: participant },
    institution: participant.institution,
    role: participant.role,
    status: :approved,
    count: 1,
    arrives_at: visit_starts_at,
    departs_at: visit_ends_at,
  )
end
