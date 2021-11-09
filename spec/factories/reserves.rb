FactoryBot.define do
  factory :reserve do
    pulldown_name { name || "Pulldown" }
    sequence(:name) { |n| "Reserve #{n}" }
    address_state { association(:state) }

    transient do
      amenities_named { [] }
    end

    after(:build) do |reserve, evaluator|
      evaluator.amenities_named.each do |name|
        reserve.amenities << build(:amenity, title: name, rates: [0])
      end
    end
    association :managing_campus, factory: :institution
  end
end
