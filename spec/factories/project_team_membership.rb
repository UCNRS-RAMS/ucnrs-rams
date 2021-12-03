FactoryBot.define do
  factory :project_team_membership do
    transient do
      project_title { "Cool Things" }
    end

    active { true }
    can_add_visit { true }
    user_role { :professional }

    project { build(:project, title: project_title) }
    association :user
  end
end
