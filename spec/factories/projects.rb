FactoryBot.define do
  factory :project do
    title { "Shh...There's Art in the Forest" }
    start_date { Date.current }
    end_date { Date.current + 1.day }
    status { "Open" }
    project_type { "Research" }
    abstract { "A project about observing art in a quiet forest" }
    discipline { "Arts/Humanities" }
    involves_mammals { false }
    involves_reptiles { false }
    involves_amphibians { false }
    involves_fish { false }
    involves_birds { false }
    involves_plants_fungi_soil { false }
    involves_none { true }
    involves_threatened_endangered_species { false }
    method_description { "Using the 5 senses in the forest" }
    method_study_area { "Deep in the forest" }
    method_remove_organisms { false }
    method_transfer_organisms { false }
    method_study_non_native_species { false }
    method_chemicals { false }
    method_soil_disturbance { false }
    method_long_term_structures { false }
    course_title { "Art Observation 101" }
    course_number { "1234" }
    submitted_at { Date.today }

    association :reserve
    association :owner, factory: :user
    association :applicant, factory: :user

    transient do
      members { [] }
    end

    after(:build) do |project, evaluator|
      evaluator.members.each do |member|
        project.team_memberships << build(
          :project_team_membership,
          user: member,
          project: project,
          active: true,
          can_add_visit: true,
        )
      end
    end
  end
end
