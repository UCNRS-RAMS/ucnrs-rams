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

# Institutions
ucnrs = Institution.where(name: "UCNRS").first_or_create(
  city: "Oakland",
  state: california,
  country: united_states,
  institution_type: :university_of_california,
)

# Reserves
uc_reserve = Reserve.where(name: "UC Reserve").first_or_create(
  short_name: "UC Reserve",
  pulldown_name: "UC Reserve",
  address_state: california,
  research_projects_accepted: true,
  class_projects_accepted: true,
  public_projects_accepted: true,
  housing_projects_accepted: true,
  conference_projects_accepted: true,
  amenity_group_label_1: "Housing",
)
yosemite_geographical_research_lab = Reserve.where(name: "Yosemite Geographical Research Laboratory").first_or_create(
  short_name: "Yosemite Geo-Lab",
  pulldown_name: "Yosemite Geographical Research Laboratory",
  address_state: california,
  research_projects_accepted: true,
  class_projects_accepted: false,
  public_projects_accepted: false,
  housing_projects_accepted: false,
  conference_projects_accepted: false,
  amenity_group_label_1: "Laboratory Space",
)
harvard_yard = Reserve.where(name: "Harvard Yard").first_or_create(
  short_name: "Harvard Yard",
  pulldown_name: "Harvard Yard",
  address_state: massachusetts,
  research_projects_accepted: false,
  class_projects_accepted: true,
  public_projects_accepted: false,
  housing_projects_accepted: false,
  conference_projects_accepted: false,
  amenity_group_label_1: "Parking Lot",
)
big_sur_conference_center = Reserve.where(name: "Big Sur Conference Center").first_or_create(
  short_name: "Big Sur Conference",
  pulldown_name: "Big Sur Conference Center",
  address_state: california,
  research_projects_accepted: false,
  class_projects_accepted: false,
  public_projects_accepted: false,
  housing_projects_accepted: false,
  conference_projects_accepted: true,
  amenity_group_label_1: "Auditoriums",
)
sunny_los_angeles_marine_center = Reserve.where(name: "Sunny Los Angeles Marine Center").first_or_create(
  short_name: "L.A. Marine Ctr.",
  pulldown_name: "Sunny Los Angeles Marine Center",
  address_state: california,
  research_projects_accepted: true,
  class_projects_accepted: true,
  public_projects_accepted: true,
  housing_projects_accepted: true,
  conference_projects_accepted: true,
  amenity_group_label_1: "Waterfront",
)

# Amenities
uc_public_housing_amenity = Amenity.where(title: "UC Public Housing Amenity").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "day",
  reserve: uc_reserve,
  visible: true,
  group_number: "1",
  amenity_rates: [
    AmenityRate.new(
      rate: 45.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Normal Price",
        reserve: uc_reserve,
        sort_order: 1,
        state_university: false,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: true,
        governmental: false,
        business: true,
        other: true,
      )
    ),
    AmenityRate.new(
      rate: 1.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "UC Price",
        reserve: uc_reserve,
        sort_order: 2,
        state_university: true,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: false,
        governmental: false,
        business: false,
        other: false,
      )
    ),
    AmenityRate.new(
      rate: 3.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Government Rate",
        reserve: uc_reserve,
        sort_order: 3,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: false,
        governmental: true,
        business: false,
        other: false,
      )
    ),
  ]
)
day_use = Amenity.where(title: "Day Use").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "day",
  reserve: yosemite_geographical_research_lab,
  visible: true,
  group_number: "1",
  amenity_rates: [
    AmenityRate.new(
      rate: 12.50,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Normal Price",
        reserve: yosemite_geographical_research_lab,
        sort_order: 1,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: true,
        governmental: false,
        business: true,
        other: true,
      )
    ),
    AmenityRate.new(
      rate: 1.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "EDU Rate",
        reserve: yosemite_geographical_research_lab,
        sort_order: 2,
        state_university: true,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: false,
        governmental: false,
        business: false,
        other: false,
      )
    ),
    AmenityRate.new(
      rate: 3.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Government Rate",
        reserve: yosemite_geographical_research_lab,
        sort_order: 3,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: false,
        governmental: true,
        business: false,
        other: false,
      )
    ),
  ]
)
botanical_garden_pavillion = Amenity.where(title: "Botanical Garden Pavillion").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "hour",
  reserve: harvard_yard,
  visible: true,
  group_number: "1",
  amenity_rates: [
    AmenityRate.new(
      rate: 15.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Normal Price",
        reserve: harvard_yard,
        sort_order: 1,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: true,
        governmental: false,
        business: true,
        other: true,
      )
    ),
    AmenityRate.new(
      rate: 14.99,
      amenity_rate_category: AmenityRateCategory.new(
        description: "EDU Rate",
        reserve: harvard_yard,
        sort_order: 2,
        state_university: true,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: false,
        governmental: false,
        business: false,
        other: false,
      )
    ),
    AmenityRate.new(
      rate: 10.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Government Rate",
        reserve: harvard_yard,
        sort_order: 3,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: false,
        governmental: true,
        business: false,
        other: false,
      )
    ),
  ]
)
auditorium_one = Amenity.where(title: "Auditorium #1").first_or_create(
  sort_order: 1,
  units_type: "facility",
  time_type: "4 hours",
  reserve: big_sur_conference_center,
  visible: true,
  group_number: "1",
  amenity_rates: [
    AmenityRate.new(
      rate: 500.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Normal Price",
        reserve: big_sur_conference_center,
        sort_order: 1,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: true,
        governmental: false,
        business: true,
        other: true,
      )
    ),
    AmenityRate.new(
      rate: 50.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "EDU Rate",
        reserve: big_sur_conference_center,
        sort_order: 2,
        state_university: true,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: false,
        governmental: false,
        business: false,
        other: false,
      )
    ),
    AmenityRate.new(
      rate: 75.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Government Rate",
        reserve: big_sur_conference_center,
        sort_order: 3,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: false,
        governmental: true,
        business: false,
        other: false,
      )
    ),
  ]
)
beach_access = Amenity.where(title: "Beach Access").first_or_create(
  sort_order: 1,
  units_type: "use",
  time_type: "day",
  reserve: sunny_los_angeles_marine_center,
  visible: true,
  group_number: "1",
  amenity_rates: [
    AmenityRate.new(
      rate: 29.99,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Normal Price",
        reserve: sunny_los_angeles_marine_center,
        sort_order: 1,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: true,
        governmental: false,
        business: true,
        other: true,
      )
    ),
    AmenityRate.new(
      rate: 0.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "EDU Rate",
        reserve: sunny_los_angeles_marine_center,
        sort_order: 2,
        state_university: true,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: false,
        governmental: false,
        business: false,
        other: false,
      )
    ),
    AmenityRate.new(
      rate: 20.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Government Rate",
        reserve: sunny_los_angeles_marine_center,
        sort_order: 3,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: false,
        governmental: true,
        business: false,
        other: false,
      )
    ),
  ]
)

# Users
public_project_owner = User.where(email: "public-project@ucnrs.org").first_or_create(
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
user = User.where(email: "project-owner@ucnrs.org").first_or_create(
  first_name: "Project",
  last_name: "Owner",
  role: "Docent",
  emergency_contact_full_name: "Emergency Contact",
  emergency_contact_phone_number: "000 867 5309",
  phone_number: "000 867 5309",
  address_line_1: "456 Main St.",
  address_city: "San Francisco",
  address_state: california,
  address_country: united_states,
  address_postal_code: "11111",
  terms_accepted_at: 5.years.ago,
  institution: ucnrs,
  password: "PR0JECTowner",
)

# Projects
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
Project.where(title: "Caldera Eruption Prevention Research").first_or_create(
  owner: user,
  applicant: user,
  reserve: yosemite_geographical_research_lab,
  project_type: :research,
  start_date: Date.new(2001, 1, 1),
  end_date: Date.new(2099, 1, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "How to Park Your Car in...").first_or_create(
  owner: user,
  applicant: user,
  reserve: harvard_yard,
  project_type: :class,
  start_date: Date.new(2015, 6, 1),
  end_date: Date.new(2025, 6, 1),
  status: 'Open',
  permits_completed: true,
)
Project.where(title: "Big Sur Conference").first_or_create(
  owner: user,
  applicant: user,
  reserve: big_sur_conference_center,
  project_type: :meeting,
  start_date: Date.new(2005, 4, 1),
  end_date: Date.new(2028, 4, 1),
  status: 'Open',
  permits_completed: true,
)

involvements = ["", :mammal, :reptile, :amphibian, :fish, :bird, :plant_fungus_soil, :threatened_endangered]
[:federal, :state, :local, :institution].each do |authority|
  8.times do |index|
    Permit.where(question: "Does this project violate #{authority} #{involvements[index]} law?").first_or_create(
      authority: authority,
      sort_order: 1,
      description: "If so, you should check the laws:",
      url1: "https://law.com",
      url1_description: "All About Law",
      url2: "https://dontbreakthe.law",
      url2_description: "Don't Break the Law",
      visible: true,
      research: true,
      university_class: true,
      conference: true,
      public: true,
      housing: true,
      involves_all: index == 0,
      involves_mammals: index == 1,
      involves_reptiles: index == 2,
      involves_amphibians: index == 3,
      involves_fish: index == 4,
      involves_birds: index == 5,
      involves_plants_fungi_soil: index == 6,
      threatened_endangered_flag: index == 7,
      statement: "#{authority} #{involvements[index]} law is violated",
    )
  end
end
