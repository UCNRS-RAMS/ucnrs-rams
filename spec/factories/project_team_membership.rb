FactoryBot.define do
  factory :project_team_membership do
    transient do
      project_title { "Cool Things" }
    end

    active { true }

    project { build(:project, title: project_title) }
    association :user
  end
end
