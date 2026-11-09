FactoryBot.define do
  factory :project_reserve_interest do
    association :project
    association :reserve
  end
end
