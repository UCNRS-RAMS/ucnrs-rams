FactoryBot.define do
  factory :reserve_note do
    note { "Gate code changed on Tuesday." }

    association :user
    association :reserve
    association :record, factory: :visit
  end
end
