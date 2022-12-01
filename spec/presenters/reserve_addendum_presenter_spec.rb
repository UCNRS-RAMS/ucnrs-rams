require "rails_helper"

RSpec.describe ReserveAddendumPresenter do
  describe "delegations" do
    subject { ReserveAddendumPresenter.new(build(:reserve_addendum)) }
    it { is_expected.to delegate_method(:id).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:sort_order).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:name).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:content).to(:reserve_addendum) }
  end
end
