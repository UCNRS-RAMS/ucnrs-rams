# Institutions
fake_university = Institution.where(name:  "Totally a Real University").first_or_create(
  city: "Real Place",
  state: State.coded("MA"),
  country: Country.coded("US"),
  institution_type: "non_california_us_university_or_college",
)

# Users
fake_user = User.where(email: "mister@moustache.test").first_or_create(
  first_name: "Mister",
  last_name: "Moustache",
  address_line_1: "213 Main St.",
  address_city: "United States City",
  address_postal_code: "00001",
  address_state: State.coded("CA"),
  address_country: Country.coded("US"),
  phone_number: "1112223333",
  emergency_contact_full_name: "Missus Moustache",
  emergency_contact_phone_number: "1112223333",
  institution: fake_university,
  role: "faculty",
  password: "F4keLOL!",
  terms_accepted_at: Time.current,
)
fake_user.confirm

# Reserves
a_single_tree = Reserve.where(name: "A Single Tree").first_or_create(
  short_name: "Tree",
  pulldown_name: "Single Tree, A",
  address_state: State.coded("MA"),
  research_projects_accepted: true,
  class_projects_accepted: false,
  conference_projects_accepted: true,
  public_projects_accepted: false,
  amenity_group_label_1: "Fun Things",
  amenity_group_label_2: "Stuff to Get",
  amenity_group_label_3: "Accomodations",
)
oak_ridge = Reserve.where(name: "Oak Ridge").first_or_create(
  short_name: "Oak Ridge",
  pulldown_name: "Oak Ridge",
  address_state: State.coded("CA"),
  research_projects_accepted: false,
  class_projects_accepted: true,
  conference_projects_accepted: true,
  public_projects_accepted: false,
  amenity_group_label_1: "ATV Vroooooooom",
  amenity_group_label_2: "Only One Acorn, Okay?",
  amenity_group_label_3: "(Not) Spooky Cabin",
)

# Amenities
leaf_pile = Amenity.where(title: "Leaf Pile").first_or_create(
  sort_order: 2,
  units_type: "person",
  time_type: "4 hours",
  reserve: a_single_tree,
  visible: true,
  group_number: "1",
  amenity_rates: [AmenityRate.new(
    rate: 10.01,
    amenity_rate_category: AmenityRateCategory.new(
      description: "Normal Price",
      reserve: a_single_tree,
      sort_order: 2
    )
  )]
)
day_use = Amenity.where(title: "Day Use").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "day",
  reserve: a_single_tree,
  visible: true,
  group_number: "1",
  amenity_rates: [AmenityRate.new(
    rate: 0,
    amenity_rate_category: AmenityRateCategory.new(
      description: "Normal Price",
      reserve: a_single_tree,
      sort_order: 1
    )
  )]
)
your_own_leaf = Amenity.where(title: "Your Own Leaf").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "each",
  reserve: a_single_tree,
  visible: true,
  group_number: "2",
  amenity_rates: [AmenityRate.new(
    rate: 999.99,
    amenity_rate_category: AmenityRateCategory.new(
      description: "Normal Price",
      reserve: a_single_tree,
      sort_order: 1
    )
  )]
)
hotel_accomodations = Amenity.where(title: "Hotel Accomodations").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "night",
  reserve: a_single_tree,
  visible: true,
  group_number: "3",
  amenity_rates: [AmenityRate.new(
    rate: 15.44,
    amenity_rate_category: AmenityRateCategory.new(
      description: "Normal Price",
      reserve: a_single_tree,
      sort_order: 1
    )
  )]
)
friendly_squirrel = Amenity.where(title: "Friendly Squirrel").first_or_create(
  sort_order: 5,
  units_type: "person",
  time_type: "night",
  reserve: a_single_tree,
  visible: true,
  group_number: "3",
  amenity_rates: [AmenityRate.new(
    rate: 1.23,
    amenity_rate_category: AmenityRateCategory.new(
      description: "Normal Price",
      reserve: a_single_tree,
      sort_order: 1
    )
  )]
)
atv_rental = Amenity.where(title: "ATV Rental").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "day",
  reserve: oak_ridge,
  visible: true,
  group_number: "1",
  amenity_rates: [AmenityRate.new(
    rate: 30,
    amenity_rate_category: AmenityRateCategory.new(
      description: "Normal Price",
      reserve: oak_ridge,
      sort_order: 1
    )
  )]
)
your_own_acorn = Amenity.where(title: "Your Own Acorn").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "each",
  reserve: oak_ridge,
  visible: true,
  group_number: "2",
  amenity_rates: [AmenityRate.new(
    rate: 0.5,
    amenity_rate_category: AmenityRateCategory.new(
      description: "Normal Price",
      reserve: oak_ridge,
      sort_order: 1
    )
  )]
)
cabin_in_the_woods = Amenity.where(title: "Cabin in the Woods").first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "night",
  reserve: oak_ridge,
  visible: true,
  group_number: "3",
  amenity_rates: [AmenityRate.new(
    rate: 78,
    amenity_rate_category: AmenityRateCategory.new(
      description: "Normal Price",
      reserve: oak_ridge,
      sort_order: 1
    )
  )]
)

# Projects
sap_study = Project.where(title: "Concentrations of Bovine Matter In Sapwood of A Single Tree Over The Course Of 30 Years").first_or_create(
  reserve: a_single_tree,
  owner: fake_user,
  applicant: fake_user,
  project_type: "research",
  start_date: 20.years.ago,
  end_date: 10.years.from_now,
  team_memberships: [ProjectTeamMembership.new(
    user: fake_user,
    institution: nil,
    active: true,
    can_add_visit: true,
  )]
)
oak_ridge_ecology = Project.where(title: "The Ecology of Oaks and Ridges and Oaks on Ridges").first_or_create(
  reserve: oak_ridge,
  owner: fake_user,
  applicant: fake_user,
  project_type: "class",
  start_date: 1.day.from_now,
  end_date: (1.year + 1.day).from_now,
  team_memberships: [ProjectTeamMembership.new(
    user: fake_user,
    institution: nil,
    active: true,
    can_add_visit: true,
  )]
)
