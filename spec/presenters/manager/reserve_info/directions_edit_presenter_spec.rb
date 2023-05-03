require "rails_helper"

RSpec.describe Manager::ReserveInfo::DirectionsEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::DirectionsEditPresenter.new(reserve: build(:reserve), form: ReserveForm.new()) }
    it { is_expected.to delegate_method(:id).to(:form) }
    it { is_expected.to delegate_method(:errors).to(:form) }
  end
end
