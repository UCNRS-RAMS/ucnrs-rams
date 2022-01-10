FactoryBot.define do
  factory :project_permit_answer do
    answer { false }

    association :permit
    association :project
  end
end
