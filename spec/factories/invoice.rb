FactoryBot.define do
  factory :invoice do
    association :visit
    notes {"Note for invoice"}
    balance_due { 0.0 }
  end
end
