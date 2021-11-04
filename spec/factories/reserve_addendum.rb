FactoryBot.define do
  factory :reserve_addendum do
    reserve
    subject { "Additional Information" }
    sequence(:sort_order) { |i| i }
  end
end
