FactoryBot.define do
  factory :visit do
    sequence(:sign_token) { |n| "token#{n}" }
    association :project
    association :reserve
    association :user
    project_type { :research }
    purpose_of_visit do
      "Same thing we do every night. Try to take over the world!"
    end
  end
end
