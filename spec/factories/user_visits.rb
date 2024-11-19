FactoryBot.define do
  factory :user_visit do
    arrives_at { Time.current.beginning_of_day }
    departs_at { Time.current.end_of_day + 1.day }
    count { 1 }
    role { :faculty }

    association :visit
    association :user
    association :institution
  end
end
