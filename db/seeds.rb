# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development?
  require 'factory_bot'

  ActiveRecord::Base.transaction do
    # Countries
    Country.destroy_all
    united_states = FactoryBot.create(:country, name: "United States", code: "US")
  
    # States
    State.destroy_all
    massachusetts = FactoryBot.create(:state, name: "Massachusetts", code: "MA", country: united_states)
    california = FactoryBot.create(:state, name: "California", code: "CA", country: united_states)
  
    # Institution
    Institution.delete_all
    fake_university = FactoryBot.create(
      :institution,
      name: "Totally a Real University",
      city: "Real Place",
      state: massachusetts,
      country: united_states,
      institution_type: "non_california_us_university_or_college",
    )
  
    # Users
    User.destroy_all
    fake_user = FactoryBot.create(
      :user,
      :confirmed,
      first_name: "Mister",
      last_name: "Moustache",
      address_line_1: "213 Main St.",
      address_city: "United States City",
      address_postal_code: "00001",
      address_state: california,
      address_country: united_states,
      email: "mister@moustache.test",
      phone_number: "1112223333",
      emergency_contact_full_name: "Missus Moustache",
      emergency_contact_phone_number: "1112223333",
      institution: fake_university,
      role: "faculty",
      password: "F4keLOL!",
    )
  
    # Reserves
    Reserve.destroy_all
    a_single_tree = FactoryBot.create(
      :reserve,
      name: "A Single Tree",
      short_name: "Tree",
      pulldown_name: "Single Tree, A",
      address_state: massachusetts,
      research_projects_accepted: true,
      class_projects_accepted: false,
      conference_projects_accepted: true,
      public_projects_accepted: false,
      amenity_group_label_1: "Fun Things",
      amenity_group_label_2: "Stuff to Get",
      amenity_group_label_3: "Accomodations",
    )
    oak_ridge = FactoryBot.create(
      :reserve,
      name: "Oak Ridge",
      short_name: "Oak Ridge",
      pulldown_name: "Oak Ridge",
      address_state: california,
      research_projects_accepted: false,
      class_projects_accepted: true,
      conference_projects_accepted: true,
      public_projects_accepted: false,
      amenity_group_label_1: "ATV Vroooooooom",
      amenity_group_label_2: "Only One Acorn, Okay?",
      amenity_group_label_3: "(Not) Spooky Cabin",
    )
  
    # Amenities
    leaf_pile = FactoryBot.create(
      :amenity,
      title: "Leaf Pile",
      sort_order: 1,
      units_type: "person",
      time_type: "4 hours",
      reserve: a_single_tree,
      visible: true,
      group_number: "1",
    )
    FactoryBot.create(:amenity_rate, rate: 10.01, amenity: leaf_pile)
    day_use = FactoryBot.create(
      :amenity,
      title: "Day Use",
      sort_order: 2,
      units_type: "person",
      time_type: "day",
      reserve: a_single_tree,
      visible: true,
      group_number: "1",
    )
    FactoryBot.create(:amenity_rate, rate: 0, amenity: day_use)
    your_own_leaf = FactoryBot.create(
      :amenity,
      title: "Your Own Leaf",
      sort_order: 3,
      units_type: "person",
      time_type: "each",
      reserve: a_single_tree,
      visible: true,
      group_number: "2",
    )
    FactoryBot.create(:amenity_rate, rate: 999.99, amenity: your_own_leaf)
    hotel_accomodations = FactoryBot.create(
      :amenity,
      title: "Hotel Accomodations",
      sort_order: 4,
      units_type: "person",
      time_type: "night",
      reserve: a_single_tree,
      visible: true,
      group_number: "3",
    )
    FactoryBot.create(:amenity_rate, rate: 15.44, amenity: hotel_accomodations)
    friendly_squirrel = FactoryBot.create(
      :amenity,
      title: "Hole Up with a Friendly Squirrel",
      sort_order: 5,
      units_type: "person",
      time_type: "night",
      reserve: a_single_tree,
      visible: true,
      group_number: "3",
    )
    FactoryBot.create(:amenity_rate, rate: 1.23, amenity: friendly_squirrel)
    atv_rental = FactoryBot.create(
      :amenity,
      title: "ATV Rental",
      sort_order: 1,
      units_type: "person",
      time_type: "day",
      reserve: oak_ridge,
      visible: true,
      group_number: "1",
    )
    FactoryBot.create(:amenity_rate, rate: 30, amenity: atv_rental)
    your_own_acorn = FactoryBot.create(
      :amenity,
      title: "Your Own Acorn",
      sort_order: 2,
      units_type: "person",
      time_type: "each",
      reserve: oak_ridge,
      visible: true,
      group_number: "2",
    )
    FactoryBot.create(:amenity_rate, rate: 0.5, amenity: your_own_acorn)
    cabin_in_the_woods = FactoryBot.create(
      :amenity,
      title: "Not At All Creepy Cabin",
      sort_order: 3,
      units_type: "person",
      time_type: "night",
      reserve: oak_ridge,
      visible: true,
      group_number: "3",
    )
    FactoryBot.create(:amenity_rate, rate: 78, amenity: cabin_in_the_woods)
  
    # Projects
    Project.destroy_all
    sap_study = FactoryBot.create(
      :project,
      reserve: a_single_tree,
      owner: fake_user,
      applicant: fake_user,
      title: "Concentrations of Bovine Matter In Sapwood of A Single Tree Over The Course Of 30 Years",
      project_type: "research",
      start_date: 20.years.ago,
      end_date: 10.years.from_now,
    )
    oak_ridge_ecology = FactoryBot.create(
      :project,
      reserve: oak_ridge,
      owner: fake_user,
      applicant: fake_user,
      title: "The Ecology of Oaks and Ridges and Oaks on Ridges",
      project_type: "class",
      start_date: 1.day.from_now,
      end_date: (1.year + 1.day).from_now,
    )
  
    # Project Team Memberships
    FactoryBot.create(
      :project_team_membership,
      project: sap_study,
      user: fake_user,
      institution: nil,
      active: true,
      can_add_visit: true,
    )
    FactoryBot.create(
      :project_team_membership,
      project: oak_ridge_ecology,
      user: fake_user,
      institution: nil,
      active: true,
      can_add_visit: true,
    )
  end
end
