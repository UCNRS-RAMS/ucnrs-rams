require "rails_helper"

RSpec.describe ReservePermitPresenter do
  describe "delegations" do
    subject { ReservePermitPresenter.new(build :reserve_permit) }
    it { is_expected.to delegate_method(:question).to(:permit).with_prefix(true) }
    it { is_expected.to delegate_method(:description).to(:permit).with_prefix(true) }
    it { is_expected.to delegate_method(:permit).to(:reserve_permit) }
    it { is_expected.to delegate_missing_methods_to(:reserve_permit) }
  end

  describe "#icon" do
    context "when the supplied value is true" do
      it "is the check icon" do
        reserve_permit = create(:reserve_permit, visible: true)
        presenter = ReservePermitPresenter.new(reserve_permit)

        expect(presenter.icon(presenter.visible)).to eq "check.svg"
      end
    end

    context "when the supplied value is false" do
      it "is the uncheck icon" do
        reserve_permit = create(:reserve_permit, visible: false)
        presenter = ReservePermitPresenter.new(reserve_permit)

        expect(presenter.icon(presenter.visible)).to eq "dot.svg"
      end
    end
  end
end
