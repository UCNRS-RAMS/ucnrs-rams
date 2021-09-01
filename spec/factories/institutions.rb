FactoryBot.define do
  factory :institution do
    name { "University of California, San Francisco" }
    city { "San Francisco" }
    institution_type { :university_of_california }

    association :country
    association :state
  end
end
