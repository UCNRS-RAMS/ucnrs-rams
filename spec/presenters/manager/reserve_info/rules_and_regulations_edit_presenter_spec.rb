require "rails_helper"

RSpec.describe Manager::ReserveInfo::RulesAndRegulationsEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::RulesAndRegulationsEditPresenter.new(reserve: build(:reserve), form: ReserveForm.new()) }
    it { is_expected.to delegate_method(:id).to(:form) }
    it { is_expected.to delegate_method(:errors).to(:form) }
    it { is_expected.to delegate_method(:rules).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:rules_url).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:code_of_conduct_url).to(:reserve).with_prefix(true) }
  end
end
