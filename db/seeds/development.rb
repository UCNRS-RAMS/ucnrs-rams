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
      sort_order: 1,
      state_university: false,
      state_college: true,
      community_college: true,
      other_state_institution: true,
      outside_state: true,
      international: true,
      K12: true,
      nongovernmental: true,
      governmental: true,
      business: true,
      other: true,
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
      sort_order: 1,
      state_university: false,
      state_college: true,
      community_college: true,
      other_state_institution: true,
      outside_state: true,
      international: true,
      K12: true,
      nongovernmental: true,
      governmental: true,
      business: true,
      other: true,
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
  amenity_rates: [
    AmenityRate.new(
      rate: 999.99,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Normal Price",
        reserve: a_single_tree,
        sort_order: 1,
        state_university: false,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: true,
        governmental: true,
        business: true,
        other: true,
      )
    ),
    AmenityRate.new(
      rate: 1.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "UC Rate",
        reserve: a_single_tree,
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
  ]
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
    amenity_rate_category:
      AmenityRateCategory.new(
        description: "Normal Price",
        reserve: a_single_tree,
        sort_order: 1,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: true,
        outside_state: false,
        international: true,
        K12: false,
        nongovernmental: true,
        governmental: true,
        business: true,
        other: true,
      ),
    ),
  AmenityRate.new(
    rate: 1.00,
    amenity_rate_category: 
      AmenityRateCategory.new(
        description: "EDU Rate",
        reserve: a_single_tree,
        sort_order: 2,
        state_university: true,
        state_college: true,
        community_college: true,
        other_state_institution: false,
        outside_state: true,
        international: false,
        K12: true,
        nongovernmental: false,
        governmental: false,
        business: false,
        other: false,
      ),
    )
  ]
)
friendly_squirrel = Amenity.where(title: "Friendly Squirrel").first_or_create(
  sort_order: 5,
  units_type: "person",
  time_type: "night",
  reserve: a_single_tree,
  visible: true,
  group_number: "3",
  amenity_rates: [
    AmenityRate.new(
      rate: 1.23,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Normal Price",
        reserve: a_single_tree,
        sort_order: 1,
        state_university: true,
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
      rate: 500.00,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Gov't Rate",
        reserve: a_single_tree,
        sort_order: 2,
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
      sort_order: 1,
      state_university: false,
      state_college: true,
      community_college: true,
      other_state_institution: true,
      outside_state: true,
      international: true,
      K12: true,
      nongovernmental: true,
      governmental: true,
      business: true,
      other: true,
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
      sort_order: 1,
      state_university: false,
      state_college: true,
      community_college: true,
      other_state_institution: true,
      outside_state: true,
      international: true,
      K12: true,
      nongovernmental: true,
      governmental: true,
      business: true,
      other: true,
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
  amenity_rates: [
    AmenityRate.new(
      rate: 78,
      amenity_rate_category: AmenityRateCategory.new(
        description: "Normal Price",
        reserve: oak_ridge,
        sort_order: 1,
        state_university: false,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: true,
        governmental: true,
        business: true,
        other: true,
      )
    ),
    AmenityRate.new(
      rate: 30.25,
      amenity_rate_category: AmenityRateCategory.new(
        description: "EDU Rate",
        reserve: a_single_tree,
        sort_order: 2,
        state_university: true,
        state_college: true,
        community_college: true,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: true,
        nongovernmental: false,
        governmental: true,
        business: false,
        other: false,
      )
    ),
  ]
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
