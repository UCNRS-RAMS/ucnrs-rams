require "rails_helper"

RSpec.describe InstitutionPresenter do
  describe "delegations" do
    subject { InstitutionPresenter.new(build(:institution)) }
    it { is_expected.to delegate_method(:id).to(:institution) }
    it { is_expected.to delegate_method(:name).to(:institution) }
  end
end

