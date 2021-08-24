FactoryBot.define do
  factory :user do
    trait :confirmed do
      confirmed_at { 1.minute.ago }
    end
  end
end
