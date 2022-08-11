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
    start_time { Time.current }
    end_time { Time.current + 5.days }

    start_date { Date.current }
    end_date { Date.current + 5.days }
  end
end
