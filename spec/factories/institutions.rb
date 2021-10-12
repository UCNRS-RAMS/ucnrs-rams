FactoryBot.define do
  factory :institution do
    sequence(:name) { |n| "Institution #{n}" }
    city { "San Francisco" }
    institution_type { :university_of_california }

    association :country
    association :state
  end
end
