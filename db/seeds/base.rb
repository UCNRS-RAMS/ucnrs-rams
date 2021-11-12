# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Countries
united_states = Country.where(name: "United States").first_or_create(code: "US")
  
# States
massachusetts = State.where(name: "Massachusetts").first_or_create(
  code: "MA",
  country: united_states
)
california = State.where(name: "California").first_or_create(
  code: "CA",
  country: united_states
)

ucnrs = Institution.where(name: "UCNRS").first_or_create(
  city: "Oakland",
  state: california,
  country: united_states,
  institution_type: :university_of_california,
)

uc_reserve = Reserve.where(name: "UC Reserve").first_or_create(
  short_name: "UC Reserve",
  pulldown_name: "UC Reserve",
  address_state: california,
  research_projects_accepted: true,
  class_projects_accepted: true,
  public_projects_accepted: true,
  housing_projects_accepted: true,
  conference_projects_accepted: true,
)

public_project_owner = User.where(email: "public-project@ucnrs.org")
  .first_or_create(
    first_name: "Public",
    last_name: "Use",
    role: "Faculty",
    emergency_contact_full_name: "Uncle Sam",
    emergency_contact_phone_number: "508 424 2424",
    phone_number: "508 424 2424",
    address_line_1: "123 Main St.",
    address_city: "Sacramento",
    address_state: california,
    address_country: united_states,
    address_postal_code: "99999",
    terms_accepted_at: 10.years.ago,
    institution: ucnrs,
    password: "PUBL1Cpassword",
  )

Project.where(title: "General Day Use").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)

Project.where(title: "Community Event").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)

Project.where(title: "Other Public Event").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)

Project.where(title: "Volunteer Event").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)

Project.where(title: "Private Class (not a University level class or K-12 class").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)

Project.where(title: "K-12 Class").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)

Project.where(title: "Fundraiser Event").first_or_create(
  owner: public_project_owner,
  applicant: public_project_owner,
  reserve: uc_reserve,
  project_type: :public_use,
  start_date: Date.new(1970, 1, 1),
  end_date: Date.new(2100, 1, 1),
  status: 'Open',
  permits_completed: true,
)
