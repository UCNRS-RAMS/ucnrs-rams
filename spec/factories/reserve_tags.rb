FactoryBot.define do
  factory :reserve_tag do
    tag_type { "Ecosystem" }
    name { "Chaparral" }

    association :reserve
  end
end
