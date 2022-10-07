require "rails_helper"

RSpec.describe Visits::UsePolicyPresenter do
  describe "delegations" do
    let(:visit) { create(:visit) }
    let(:user) { create(:user) }

    subject { Visits::UsePolicyPresenter.new(visit: visit, current_user: user, current_step: 4) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#reserve_use_agreements" do
    it "returns policy agreements of 'reserve_use_agreement' order by 'sort_order'" do
      use_policy_ids = [
        create(:use_policy, agreement_type: :reserve_use_agreement, sort_order: 2).id,
        create(:use_policy, agreement_type: :reserve_use_agreement, sort_order: 1).id,
        create(:use_policy, agreement_type: :reserve_use_agreement, sort_order: 3).id
      ]
      current_user = create(:user)
      visit = create(:visit)

      presenter = Visits::UsePolicyPresenter.new(
        current_user: current_user,
        visit: visit,
        current_step: 4
      )
      result = [use_policy_ids[1], use_policy_ids[0], use_policy_ids[2]]

      expect(presenter.reserve_use_agreements.pluck(:id)).to eq result
    end
  end

  describe "#code_of_conduct_agreements" do
    it "returns policy agreements of 'code_of_conduct_agreement' order by 'sort_order'" do
      use_policy_ids = [
        create(:use_policy, agreement_type: :code_of_conduct_agreement, sort_order: 2).id,
        create(:use_policy, agreement_type: :code_of_conduct_agreement, sort_order: 1).id,
        create(:use_policy, agreement_type: :code_of_conduct_agreement, sort_order: 3).id
      ]
      current_user = create(:user)
      visit = create(:visit)

      presenter = Visits::UsePolicyPresenter.new(
        current_user: current_user,
        visit: visit,
        current_step: 4
      )

      result = [use_policy_ids[1], use_policy_ids[0], use_policy_ids[2]]

      expect(presenter.code_of_conduct_agreements.pluck(:id)).to eq result
    end
  end

  describe "#data_management_agreements" do
    it "returns policy agreements of 'data_management_agreement' order by 'sort_order'" do
      use_policy_ids = [
        create(:use_policy, agreement_type: :data_management_agreement, sort_order: 2).id,
        create(:use_policy, agreement_type: :data_management_agreement, sort_order: 1).id,
        create(:use_policy, agreement_type: :data_management_agreement, sort_order: 3).id
      ]
      current_user = create(:user)
      visit = create(:visit)

      presenter = Visits::UsePolicyPresenter.new(
        current_user: current_user,
        visit: visit,
        current_step: 4
      )

      result = [use_policy_ids[1], use_policy_ids[0], use_policy_ids[2]]

      expect(presenter.data_management_agreements.pluck(:id)).to eq result
    end
  end
end
