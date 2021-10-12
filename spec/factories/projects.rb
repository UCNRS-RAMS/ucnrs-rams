FactoryBot.define do
  factory :project do
    title { "Shh...There's Art in the Forest" }
    start_date { Date.current }
    end_date { Date.current + 1.day }

    association :reserve
    association :owner, factory: :user
    association :applicant, factory: :user
  end
end
