FactoryBot.define do
  factory :visit do
    sequence(:sign_token) { |n| "token#{n}" }
    association :project
    association :reserve
    association :user
    project_type { :research }
    created_at { Time.zone.today }
    status { :incomplete }
    purpose_of_visit do
      "Same thing we do every night. Try to take over the world!"
    end
    start_time { Time.current - 5.day }
    end_time { Time.current + 5.days }

    start_date { Date.current - 5.day }
    end_date { Date.current + 5.days }

    starts_at { Time.current - 5.day }
    ends_at { Time.current + 5.days }
  end
end
