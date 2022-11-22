FactoryBot.define do
  factory :invoice_payment do
    amount { 8 }
    paid_on { current_date }
    notes { "Hello, i am a simple note" }

    association :invoice
    association :user
  end
end
