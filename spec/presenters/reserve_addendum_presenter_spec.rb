require "rails_helper"

RSpec.describe ReserveAddendumPresenter do
  describe "delegations" do
    subject { ReserveAddendumPresenter.new(build(:reserve_addendum)) }
    it { is_expected.to delegate_method(:id).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:sort_order).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:url_link).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:url_text).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:subject).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:info_text).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:info_format).to(:reserve_addendum) }
  end
end
