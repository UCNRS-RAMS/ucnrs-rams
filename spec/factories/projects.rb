FactoryBot.define do
  factory :project do
    title { "Shh...There's Art in the Forest" }
    start_date { Date.current }
    end_date { Date.current + 1.day }
    status { "Open" }

    association :reserve
    association :owner, factory: :user
    association :applicant, factory: :user

    transient do
      members { [] }
    end

    after(:build) do |project, evaluator|
      evaluator.members.each do |member|
        project.team_members << member
      end
    end
  end
end
