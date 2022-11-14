FactoryBot.define do
  factory :invoice_recipient do
    association :user
    association :invoice
  end
end
