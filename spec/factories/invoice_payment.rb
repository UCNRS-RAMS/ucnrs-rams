FactoryBot.define do
  factory :invoice_payment do
    amount { 8 }
    paid_on { Date.today }
    notes { "Hello, i am a simple note" }

    association :invoice
    association :user
  end
end
