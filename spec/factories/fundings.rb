FactoryBot.define do
  factory :funding do
    title { "Money, just for you!" }
    is_funded { false }
    is_submitted { false }
    will_be_submitted { false }
    was_denied { false }
    principal_investigators { "Mister Moustache,Missus Moustache" }
    sponsor { :national_science_foundation }
    start_date { Date.current }
    end_date { Date.current + 1.year }

    association :project
  end
end
