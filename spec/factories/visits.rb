FactoryBot.define do
  factory :visit do
    sequence(:sign_token) { |n| "token#{n}" }
    association :project
    association :reserve
    association :user
  end
end
