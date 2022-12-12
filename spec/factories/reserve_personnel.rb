FactoryBot.define do
  factory :reserve_personnel do
    reserve { build(:reserve) }
    association :user

    trait :with_avatar_old do
      after(:build) do |reserve_personnel|
        reserve_personnel.avatar_old.attach(
          io: File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')),
          filename: 'test-image.jpeg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :with_avatar do
      after(:build) do |reserve_personnel|
        File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')) do |f|
          reserve_personnel.avatar = f
        end
      end
    end
  end
end
