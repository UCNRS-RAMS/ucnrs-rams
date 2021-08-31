FactoryBot.define do
  factory :institution do
    name { "University of California, San Francisco" }
    category_nrs { "University of California" }

    association :country
    association :state
  end
end
