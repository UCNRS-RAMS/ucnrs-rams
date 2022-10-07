require 'rails_helper'

RSpec.describe UsePolicy, type: :model do
  it do 
    is_expected.to define_enum_for(:agreement_type)
      .with_values(
        reserve_use_agreement: "Reserve Use Agreement",
        code_of_conduct_agreement: "Code of Conduct Agreement",
        data_management_agreement: "Data Management Agreement"
      ).backed_by_column_of_type(:string)
  end

  describe ".in_order" do
    it "returns use_policies order by 'sort_order'" do
      use_policy_ids = [
        create(:use_policy, agreement_type: :reserve_use_agreement, sort_order: 2).id,
        create(:use_policy, agreement_type: :reserve_use_agreement, sort_order: 1).id,
        create(:use_policy, agreement_type: :reserve_use_agreement, sort_order: 3).id
      ]

      result = [use_policy_ids[1], use_policy_ids[0], use_policy_ids[2]]

      expect(UsePolicy.in_order.pluck(:id)).to eql result
    end
  end
end
