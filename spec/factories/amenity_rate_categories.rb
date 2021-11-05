FactoryBot.define do
  factory :amenity_rate_category do
    reserve
    description { "Normal Price" }
    visible { true }
    state_university { false }
    state_college { false }
    community_college { false }
    other_state_institution { false }
    outside_state { false }
    international { false }
    add_attribute(:K12) { k12 }
    nongovernmental { false }
    governmental { false }
    business { false }
    other { false }

    transient do
      k12 { false }
    end
  end
end
