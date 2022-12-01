FactoryBot.define do
  factory :reserve_addendum do
    association :reserve
    name { "Additional Information" }
    sequence(:sort_order) { |i| i }
  end
end
