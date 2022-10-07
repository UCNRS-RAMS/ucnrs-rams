FactoryBot.define do
  factory :use_policy do
    title {"No Pets Allowed"}
    description {"Please note domestic animals are not allowed on any reserve and exceptions require written staff approval."}
    agreement_type {"data_management_agreement"}
    policy_link_text {"metadata online"}
  end
end
