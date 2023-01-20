FactoryBot.define do
  factory :reserve_tag do
    category { "ecosystem" }
    name { "Chaparral" }

    association :reserve
  end
end
