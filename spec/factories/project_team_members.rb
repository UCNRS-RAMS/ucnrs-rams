FactoryBot.define do
  factory :project_team_member do
    active { true }

    association :project
    association :user
  end
end
