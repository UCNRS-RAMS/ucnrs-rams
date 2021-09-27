require "rails_helper"

RSpec.describe WaiverPresenter do
  describe "delegations" do
    subject { WaiverPresenter.new(Waiver.new(1, "Main Waiver", "If you plan to visit more than one reserve,
      you may use this Multi-Reserve waiver form.", "pdf_link01")) }
    it { is_expected.to delegate_method(:id).to(:waiver) }
    it { is_expected.to delegate_method(:name).to(:waiver) }
    it { is_expected.to delegate_method(:description).to(:waiver) }
    it { is_expected.to delegate_method(:pdf_link).to(:waiver) }
  end
end
