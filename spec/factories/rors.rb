FactoryBot.define do
  factory :ror do
    sequence(:ror_id) { |n| "https://ror.org/0abc#{n.to_s.rjust(4, '0')}" }
    sequence(:name) { |n| "ROR Institution #{n}" }
    home_page { 'https://example.edu' }
    language { 'en' }
    types { ['Education'] }
    acronyms { ['UCSF'] }
    aliases { ['Example University'] }
    country { { 'country_code' => 'US', 'country_name' => 'United States' } }
    file_timestamp { Time.zone.now }
  end
end
