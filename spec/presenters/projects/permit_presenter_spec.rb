require "rails_helper"

RSpec.describe Projects::PermitPresenter do
  describe "delegations" do
    subject { Projects::PermitPresenter.new(build(:permit)) }
    it { is_expected.to delegate_missing_methods_to(:permit) }
  end
end
