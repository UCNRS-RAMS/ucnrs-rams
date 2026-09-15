FactoryBot.define do
  factory :api_client do
    sequence(:name) { |n| "API Client #{n}" }
    active { true }
  end
end
