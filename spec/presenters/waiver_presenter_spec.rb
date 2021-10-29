require "rails_helper"

RSpec.describe WaiverPresenter do
  describe "delegations" do
    subject { WaiverPresenter.new(build(:waiver)) }
    it { is_expected.to delegate_method(:id).to(:waiver) }
    it { is_expected.to delegate_method(:name).to(:waiver) }
    it { is_expected.to delegate_method(:description).to(:waiver) }
    it { is_expected.to delegate_method(:url).to(:waiver) }
  end
end
