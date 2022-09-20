FactoryBot.define do
  factory :annual_report do
    association :reserve
    fiscal_year_ending { Date.current.year }
  end
end
