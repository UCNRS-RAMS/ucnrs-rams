FactoryBot.define do
  factory :reserve do
    pulldown_name { name || "Pulldown" }
  end
end
