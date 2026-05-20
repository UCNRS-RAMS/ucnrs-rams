FactoryBot.define do
  factory :reserve_personnel do
    reserve { build(:reserve) }
    association :user
    sequence(:phone_number) { |n| "555-010-#{n.to_s.rjust(4, "0")}" }
    sequence(:email) { |n| "reserve_personnel_#{n}@example.com" }
    sequence(:role_title) { |n| "Reserve Staff #{n}" }

    trait :with_avatar_old do
      after(:build) do |reserve_personnel|
        reserve_personnel.avatar_old.attach(
          io: File.open(Rails.root.join("spec/support/assets/test-image.jpeg")),
          filename: 'test-image.jpeg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :with_avatar do
      after(:build) do |reserve_personnel|
        File.open(Rails.root.join("spec/support/assets/test-image.jpeg")) do |f|
          reserve_personnel.avatar = f
        end
      end
    end
  end
end
