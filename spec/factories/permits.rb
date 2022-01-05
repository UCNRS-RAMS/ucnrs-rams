FactoryBot.define do
  factory :permit do
    sort_order { 1 }
    visible { true }
    research { true }

    involves_all { false }
    involves_mammals { false }
    involves_reptiles { false }
    involves_amphibians { false }
    involves_fish { false }
    involves_birds { false }
    involves_plants_fungi_soil { false }
    involves_none { false }
    threatened_endangered_flag { false }
  end
end
