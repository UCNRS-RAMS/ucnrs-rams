FactoryBot.define do
  factory :amenity_visit do
    arrives_on { Time.current.to_date }
    departs_on { Time.current.to_date + 1.day }

    arrives_at { Time.current }
    departs_at { Time.current + 1.day }

    arrives { Time.current }
    departs { Time.current + 1.day }

    number_of_people { 1 }

    association :invoice
    association :visit
    association :amenity
    association :amenity_rate
    association :user
  end
end
