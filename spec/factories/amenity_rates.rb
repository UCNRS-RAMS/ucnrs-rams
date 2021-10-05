FactoryBot.define do
  factory :amenity_rate do
    transient do
      sort_order { 1 }
    end

    rate { 12.50 }
    amenity_rate_category { association :amenity_rate_category, sort_order: sort_order }
    amenity
  end
end
