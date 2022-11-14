FactoryBot.define do
  factory :invoice do
    association :visit
    notes {"Note for invoice"}
  end
end
