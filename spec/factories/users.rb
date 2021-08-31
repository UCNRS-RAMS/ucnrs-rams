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
    address_state_id { 1 }
    address_country_id { 1 }
    address_postal_code { "94941" }
    billing_address_address_line_1 { "1 Muir Woods Road" }
    billing_address_city { "Mill Valley" }
    billing_address_state_id { 1 }
    billing_address_country_id { 1 }
    billing_address_postal_code { "94941" }
    terms_accepted_at { Time.current }
    email { "john@muir.test" }

    trait :confirmed do
      confirmed_at { 1.minute.ago }
    end
  end
end
