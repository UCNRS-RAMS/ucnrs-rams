require "rails_helper"

RSpec.describe Manager::ReserveInfo::RulesAndRegulationsEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::RulesAndRegulationsEditPresenter.new(reserve: build(:reserve), form: ReserveForm.new()) }
    it { is_expected.to delegate_method(:id).to(:form) }
    it { is_expected.to delegate_method(:errors).to(:form) }
  end
end
