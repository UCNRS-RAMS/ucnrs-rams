# frozen_string_literal: true

united_states = Country.coded("US")

a_single_tree = DevelopmentSeeds.record(
  Reserve,
  { name: "A Single Tree" },
  short_name: "Tree",
  pulldown_name: "Single Tree, A",
  address_country: united_states,
  address_state: State.coded("MA"),
  research_projects_accepted: true,
  class_projects_accepted: false,
  conference_projects_accepted: true,
  public_projects_accepted: false,
  amenity_group_label_1: "Fun Things",
  amenity_group_label_2: "Stuff to Get",
  amenity_group_label_3: "Accommodations",
  doi: "10.0000/example.single-tree",
  latitude: 37.8044,
  longitude: -122.2712,
)

oak_ridge = DevelopmentSeeds.record(
  Reserve,
  { name: "Oak Ridge" },
  short_name: "Oak Ridge",
  pulldown_name: "Oak Ridge",
  address_country: united_states,
  address_state: State.coded("CA"),
  research_projects_accepted: false,
  class_projects_accepted: true,
  conference_projects_accepted: true,
  public_projects_accepted: false,
  amenity_group_label_1: "ATV Vroooooooom",
  amenity_group_label_2: "Only One Acorn, Okay?",
  amenity_group_label_3: "(Not) Spooky Cabin",
)

DevelopmentSeeds.record(
  ReservePersonnel,
  { reserve: a_single_tree, user: User.find_by!(email: "manager@single-tree.test") },
  role: "Administrator",
  role_title: "Reserve Manager",
  email: "manager@single-tree.test",
  phone_number: "111-222-4444",
  visible: true,
  receive_new_visit_email: false,
  receive_incomplete_visit_email: false,
  receive_update_email: false,
  receive_approval_email: false,
  receive_iacuc_email: false,
  receive_drone_email: false,
  receive_scuba_email: false,
)

category_defaults = {
  state_university: false, state_college: false, community_college: false,
  other_state_institution: false, outside_state: false, international: false,
  K12: false, nongovernmental: false, governmental: false, business: false, other: false,
}

categories = [
  [a_single_tree, "Normal Price", 1, category_defaults.transform_values { true }],
  [a_single_tree, "UC Rate", 2, { state_university: true }],
  [a_single_tree, "EDU Rate", 3, { state_university: true, state_college: true, community_college: true,
                                    outside_state: true, K12: true }],
  [a_single_tree, "Gov't Rate", 4, { governmental: true }],
  [oak_ridge, "Normal Price", 1, category_defaults.transform_values { true }],
  [oak_ridge, "EDU Rate", 2, { state_university: true, state_college: true, community_college: true,
                                K12: true, governmental: true }],
].to_h do |reserve, description, sort_order, eligibility|
  category = DevelopmentSeeds.record(
    AmenityRateCategory,
    { reserve: reserve, description: description },
    category_defaults.merge(eligibility).merge(sort_order: sort_order),
  )
  [[reserve.name, description], category]
end

amenities = [
  [a_single_tree, "Leaf Pile", 2, "person", "4 hours", "1"],
  [a_single_tree, "Day Use", 1, "person", "day", "1"],
  [a_single_tree, "Your Own Leaf", 1, "person", "each", "2"],
  [a_single_tree, "Hotel Accommodations", 1, "person", "night", "3"],
  [a_single_tree, "Friendly Squirrel", 5, "person", "night", "3"],
  [oak_ridge, "ATV Rental", 1, "person", "day", "1"],
  [oak_ridge, "Your Own Acorn", 1, "person", "each", "2"],
  [oak_ridge, "Cabin in the Woods", 1, "person", "night", "3"],
].to_h do |reserve, title, sort_order, units_type, time_type, group_number|
  amenity = DevelopmentSeeds.record(
    Amenity,
    { reserve: reserve, title: title },
    sort_order: sort_order, units_type: units_type, time_type: time_type,
    visible: true, group_number: group_number,
  )
  [[reserve.name, title], amenity]
end

[
  ["A Single Tree", "Leaf Pile", "Normal Price", 10.01],
  ["A Single Tree", "Your Own Leaf", "Normal Price", 999.99],
  ["A Single Tree", "Your Own Leaf", "UC Rate", 1.00],
  ["A Single Tree", "Hotel Accommodations", "Normal Price", 15.44],
  ["A Single Tree", "Hotel Accommodations", "EDU Rate", 1.00],
  ["A Single Tree", "Friendly Squirrel", "Normal Price", 1.23],
  ["A Single Tree", "Friendly Squirrel", "Gov't Rate", 500.00],
  ["Oak Ridge", "ATV Rental", "Normal Price", 30.00],
  ["Oak Ridge", "Your Own Acorn", "Normal Price", 0.50],
  ["Oak Ridge", "Cabin in the Woods", "Normal Price", 78.00],
  ["Oak Ridge", "Cabin in the Woods", "EDU Rate", 30.25],
].each do |reserve_name, amenity_title, category_description, rate|
  AmenityRate.find_by!(
    amenity: amenities.fetch([reserve_name, amenity_title]),
    amenity_rate_category: categories.fetch([reserve_name, category_description]),
  ).update!(rate: rate)
end
