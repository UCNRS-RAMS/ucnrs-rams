FactoryBot.define do
  factory :reserve_question do
    visible { true }
    location { :project }
    question_type { :boolean }
    association :reserve
    answer_required { false }
    public_use { true }
    university_class { true }
    research { true }
    housing { true }
    conference { true }
    trait :text_question do
      question_type { :text }
    end

    trait :boolean_question do
      question_type { :boolean }
    end
  end
end
