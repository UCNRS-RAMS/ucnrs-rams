FactoryBot.define do
  factory :amenity_rate do
    transient do
      description { "Normal Price" }
      sort_order { 1 }
    end

    rate { 12.50 }
    amenity
    amenity_rate_category do
      association :amenity_rate_category,
        reserve: amenity.reserve,
        description: description,
        sort_order: sort_order
    end
  end
end
