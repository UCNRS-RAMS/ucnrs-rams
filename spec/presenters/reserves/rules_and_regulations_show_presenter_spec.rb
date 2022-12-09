require "rails_helper"

RSpec.describe Reserves::RulesAndRegulationsShowPresenter do
  describe "delegations" do
    subject { Reserves::RulesAndRegulationsShowPresenter.new(reserve: build(:reserve)) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:rules_and_regulations).to(:reserve).with_prefix(true) }
  end
end
