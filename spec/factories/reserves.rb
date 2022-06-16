FactoryBot.define do
  factory :reserve do
    pulldown_name { name || "Pulldown" }
    sequence(:name) { |n| "Reserve #{n}" }
    address_state { association(:state) }
    amenity_group_label_1 { "Label 1" }

    transient do
      amenities_named { [] }
    end

    after(:build) do |reserve, evaluator|
      evaluator.amenities_named.each do |name|
        reserve.amenities << build(:amenity, title: name, rates: [0])
      end
    end

    association :address_country, factory: :country
    association :managing_campus, factory: :institution

    trait :with_hero_photo do
      after(:build) do |reserve|
        reserve.large_hero_photo.attach(
          io: File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')),
          filename: 'test-image.jpeg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :with_listing_photo do
      after(:build) do |reserve|
        reserve.listing_photo.attach(
          io: File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')),
          filename: 'test-image.jpeg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
