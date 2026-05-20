FactoryBot.define do
  factory :reserve do
    pulldown_name { name || "Pulldown" }
    sequence(:name) { |n| "Reserve #{n}" }
    address_state { association(:state) }
    amenity_group_label_1 { "Label 1" }
    public_calendar_access { true }

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

    trait :with_full_address do
      address_line_1 { "123 Reserve Road" }
      address_line_2 { "Suite 100" }
      address_city { "Berkeley" }
      address_postal_code { "94720" }
      association :managing_campus, factory: :institution
    end

    trait :with_rules_and_directions do
      rules_and_regulations { "All visitors must sign in at the station before entering the reserve." }
      directions { "Take Highway 1 north, turn left at the reserve entrance sign." }
    end

    trait :with_logo do
      after(:build) do |reserve|
        File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')) do |f|
          reserve.logo = f
        end
      end
    end

    trait :with_hero_photo do
      after(:build) do |reserve|
        File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')) do |f|
          reserve.large_hero_photo = f
        end
      end
    end

    trait :with_listing_photo do
      after(:build) do |reserve|
        File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')) do |f|
          reserve.listing_photo = f
        end
      end
    end

    trait :with_invalid_file_format do
      after(:build) do |reserve|
        File.open(Rails.root.join("spec", "support", "assets", "test-file.pdf")) do |f|
          reserve.listing_photo = f
          reserve.large_hero_photo = f
        end
      end
    end
  end
end
