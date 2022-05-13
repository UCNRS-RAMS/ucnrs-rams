require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveDetailsIndexPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::ReserveDetailsIndexPresenter.new(reserve: build(:reserve)) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
  end

end
