require "rails_helper"

RSpec.describe StatePresenter do
  describe "delegations" do
    subject { StatePresenter.new(build(:state)) }
    it { is_expected.to delegate_method(:id).to(:state) }
    it { is_expected.to delegate_method(:name).to(:state) }
  end
end
