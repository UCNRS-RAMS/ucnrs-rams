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

    trait :with_listing_photo do
      after(:build) do |amenity|
        File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')) do |f|
          amenity.listing_photo = f
        end
      end
    end

    after(:build) do |amenity, evaluator|
      evaluator.rates.each do |rate|
        amenity.amenity_rates << build(:amenity_rate, rate: rate)
      end
    end
  end
end
