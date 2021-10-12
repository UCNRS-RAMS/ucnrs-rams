FactoryBot.define do
  factory :reserve do
    pulldown_name { name || "Pulldown" }
    sequence(:name) { |n| "Reserve #{n}" }
  end
end
