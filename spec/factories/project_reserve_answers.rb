FactoryBot.define do
  factory :project_reserve_answer do
    association :project
    association :reserve_question
  end
end
