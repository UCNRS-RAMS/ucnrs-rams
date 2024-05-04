FactoryBot.define do
  factory :log do
    association :user
    association :record, factory: :project
  end
end
