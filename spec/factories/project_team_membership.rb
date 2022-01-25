FactoryBot.define do
  factory :project_team_membership do
    transient do
      project_title { "Cool Things" }
    end

    active { true }
    can_add_visit { true }
    can_edit_project { true }
    user_role { :professional }

    project { build(:project, title: project_title) }
    association :user
    association :institution

    trait :principal_investigator do
      is_principal_investigator { true }
      can_edit_project { true }
      can_add_project_user { true }
      can_add_visit { true }
      can_receive_invoice { true }
    end

    trait :project_manager do
      is_principal_investigator { false }
      can_edit_project { true }
      can_add_project_user { true }
      can_add_visit { true }
      can_receive_invoice { false }
    end

    trait :team_member do
      is_principal_investigator { false }
      can_edit_project { false }
      can_add_project_user { true }
      can_add_visit { true }
      can_receive_invoice { false }
    end

    trait :billing do
      is_principal_investigator { false }
      can_edit_project { false }
      can_add_project_user { false }
      can_add_visit { true }
      can_receive_invoice { true }
    end
  end
end
