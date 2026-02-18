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
  address_country: Country.coded("US"),
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
  address_country: Country.coded("US"),
  address_state: State.coded("CA"),
  research_projects_accepted: false,
  class_projects_accepted: true,
  conference_projects_accepted: true,
  public_projects_accepted: false,
  amenity_group_label_1: "ATV Vroooooooom",
  amenity_group_label_2: "Only One Acorn, Okay?",
  amenity_group_label_3: "(Not) Spooky Cabin",
)

# Amenity Rate Categories for A Single Tree
tree_normal_price = AmenityRateCategory.where(description: "Normal Price", reserve_id: a_single_tree.id).first_or_create(
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

tree_uc_rate = AmenityRateCategory.where(description: "UC Rate", reserve_id: a_single_tree.id).first_or_create(
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

tree_edu_rate = AmenityRateCategory.where(description: "EDU Rate", reserve_id: a_single_tree.id).first_or_create(
  reserve: a_single_tree,
  sort_order: 3,
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
)

tree_govt_rate = AmenityRateCategory.where(description: "Gov't Rate", reserve_id: a_single_tree.id).first_or_create(
  reserve: a_single_tree,
  sort_order: 4,
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

# Amenity Rate Categories for Oak Ridge
oak_normal_price = AmenityRateCategory.where(description: "Normal Price", reserve_id: oak_ridge.id).first_or_create(
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

oak_edu_rate = AmenityRateCategory.where(description: "EDU Rate", reserve_id: oak_ridge.id).first_or_create(
  reserve: oak_ridge,
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

# Amenities
# Note: after_create callbacks automatically create AmenityRate records with rate: 0.0
# for all existing categories when an Amenity is created
leaf_pile = Amenity.where(title: "Leaf Pile", reserve: a_single_tree).first_or_create(
  sort_order: 2,
  units_type: "person",
  time_type: "4 hours",
  reserve: a_single_tree,
  visible: true,
  group_number: "1",
)
AmenityRate.find_by(amenity: leaf_pile, amenity_rate_category: tree_normal_price)&.update(rate: 10.01)

day_use = Amenity.where(title: "Day Use", reserve: a_single_tree).first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "day",
  reserve: a_single_tree,
  visible: true,
  group_number: "1",
)
# Day Use stays at 0 by default

your_own_leaf = Amenity.where(title: "Your Own Leaf", reserve: a_single_tree).first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "each",
  reserve: a_single_tree,
  visible: true,
  group_number: "2",
)
AmenityRate.find_by(amenity: your_own_leaf, amenity_rate_category: tree_normal_price)&.update(rate: 999.99)
AmenityRate.find_by(amenity: your_own_leaf, amenity_rate_category: tree_uc_rate)&.update(rate: 1.00)

hotel_accomodations = Amenity.where(title: "Hotel Accomodations", reserve: a_single_tree).first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "night",
  reserve: a_single_tree,
  visible: true,
  group_number: "3",
)
AmenityRate.find_by(amenity: hotel_accomodations, amenity_rate_category: tree_normal_price)&.update(rate: 15.44)
AmenityRate.find_by(amenity: hotel_accomodations, amenity_rate_category: tree_edu_rate)&.update(rate: 1.00)

friendly_squirrel = Amenity.where(title: "Friendly Squirrel", reserve: a_single_tree).first_or_create(
  sort_order: 5,
  units_type: "person",
  time_type: "night",
  reserve: a_single_tree,
  visible: true,
  group_number: "3",
)
AmenityRate.find_by(amenity: friendly_squirrel, amenity_rate_category: tree_normal_price)&.update(rate: 1.23)
AmenityRate.find_by(amenity: friendly_squirrel, amenity_rate_category: tree_govt_rate)&.update(rate: 500.00)

atv_rental = Amenity.where(title: "ATV Rental", reserve: oak_ridge).first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "day",
  reserve: oak_ridge,
  visible: true,
  group_number: "1",
)
AmenityRate.find_by(amenity: atv_rental, amenity_rate_category: oak_normal_price)&.update(rate: 30)

your_own_acorn = Amenity.where(title: "Your Own Acorn", reserve: oak_ridge).first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "each",
  reserve: oak_ridge,
  visible: true,
  group_number: "2",
)
AmenityRate.find_by(amenity: your_own_acorn, amenity_rate_category: oak_normal_price)&.update(rate: 0.5)

cabin_in_the_woods = Amenity.where(title: "Cabin in the Woods", reserve: oak_ridge).first_or_create(
  sort_order: 1,
  units_type: "person",
  time_type: "night",
  reserve: oak_ridge,
  visible: true,
  group_number: "3",
)
AmenityRate.find_by(amenity: cabin_in_the_woods, amenity_rate_category: oak_normal_price)&.update(rate: 78)
AmenityRate.find_by(amenity: cabin_in_the_woods, amenity_rate_category: oak_edu_rate)&.update(rate: 30.25)

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
