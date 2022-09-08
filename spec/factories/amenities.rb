FactoryBot.define do
  factory :amenity do
    sequence(:sort_order)
    sequence(:title) { |n| "Amenity #{n}" }
    description { "Description" }
    time_type { "day" }
    units_type { "facility" }
    group_number { "1" }
    amenities_type { "vehicles_and_boats" }
    reserve

    transient do
      rates { [] }
    end

    after(:build) do |amenity, evaluator|
      evaluator.rates.each do |rate|
        amenity.amenity_rates << build(:amenity_rate, rate: rate)
      end
    end
  end
end
