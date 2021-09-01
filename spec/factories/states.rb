FactoryBot.define do
  factory :state do
    name { "California" }
    code { "CA" }

    association :country
  end
end
