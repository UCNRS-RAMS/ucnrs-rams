FactoryBot.define do
  factory :amenity_visit do
    arrives_at { Time.current }
    departs_at { Time.current + 1.day }

    arrives { Time.current }
    departs { Time.current + 1.day }

    number_of_people { 1 }
    invoice_id { 0 }
    association :visit
    association :amenity
    association :amenity_rate
    association :user
  end
end
