FactoryBot.define do
  factory :project do
    title { "Shh...There's Art in the Forest" }
    start_date { Date.current }
    end_date { Date.current + 1.day }
    status { "Open" }
    project_type { "Research" }
    abstract { "A project about observing art in a quiet forest"}

    association :reserve
    association :owner, factory: :user
    association :applicant, factory: :user

    transient do
      members { [] }
    end

    after(:build) do |project, evaluator|
      evaluator.members.each do |member|
        project.team_memberships << build(
          :project_team_membership,
          user: member,
          project: project,
          active: true,
          can_add_visit: true,
        )
      end
    end
  end
end
