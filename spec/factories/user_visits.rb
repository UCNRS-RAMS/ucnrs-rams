FactoryBot.define do
  factory :user_visit do
    arrives_at { Time.current }
    departs_at { Time.current + 1.day }

    association :visit
    association :user
    association :institution
  end
end
