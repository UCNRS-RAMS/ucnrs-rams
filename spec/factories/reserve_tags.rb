FactoryBot.define do
  factory :reserve_tag do
    category { "Ecosystem" }
    name { "Chaparral" }

    association :reserve
  end
end
