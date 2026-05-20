FactoryBot.define do
  factory :waiver do
    name { "Waiver 1" }

    trait :with_full_info do
      description { "This waiver must be signed before accessing the reserve." }
      url { "https://example.com/waiver" }
    end
  end
end
