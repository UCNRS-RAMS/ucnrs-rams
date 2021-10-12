FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Muir" }
    role { :research_scientist }
    emergency_contact_full_name { "Louisa Wanda Strentzel" }
    emergency_contact_phone_number { "111-111-1111" }
    phone_number { "222-222-2222" }
    address_line_1 { "1 Muir Woods Road" }
    address_city { "Mill Valley" }
    address_postal_code { "94941" }
    terms_accepted_at { Time.current }
    password { "Password1" }
    sequence(:email) { |n| "john@muir#{n}.test" }

    association :institution, factory: :institution
    association :address_country, factory: :country

    trait :confirmed do
      confirmed_at { 1.minute.ago }
    end
  end
end
