FactoryBot.define do
  factory :reserve_question do
    association :reserve

    question_type { "Text" }
    answer_required { false }
    public_use { true }
    university_class { true }
    research { true }
    housing { true }
    conference { true }
  end
end
