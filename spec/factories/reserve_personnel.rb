FactoryBot.define do
  factory :reserve_personnel do
    reserve { build(:reserve) }
    association :user

    trait :with_avatar do
      after(:build) do |reserve_personnel|
        reserve_personnel.avatar.attach(
          io: File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg')),
          filename: 'test-image.jpeg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
