FactoryBot.define do
  factory :reserve_permit do
    association :permit
    association :reserve
  end
end
