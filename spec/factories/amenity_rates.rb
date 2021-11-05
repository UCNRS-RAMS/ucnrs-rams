FactoryBot.define do
  factory :amenity_rate do
    transient do
      description { "Normal Price" }
      sort_order { 1 }
      visible { true }
      state_university { false }
      state_college { false }
      community_college { false }
      other_state_institution { false }
      outside_state { false }
      international { false }
      k12 { false }
      nongovernmental { false }
      governmental { false }
      business { false }
      other { false }
    end

    rate { 12.50 }
    amenity
    amenity_rate_category do
      association(
        :amenity_rate_category,
        reserve: amenity.reserve,
        description: description,
        sort_order: sort_order,
        visible: visible, 
        state_university: state_university, 
        state_college: state_college, 
        community_college: community_college, 
        other_state_institution: other_state_institution, 
        outside_state: outside_state, 
        international: international, 
        k12: k12,
        nongovernmental: nongovernmental, 
        governmental: governmental, 
        business: business, 
        other: other, 
      )
    end
  end
end
