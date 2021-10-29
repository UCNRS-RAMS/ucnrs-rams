FactoryBot.define do
  factory :amenity do
    description { "Description" }
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
