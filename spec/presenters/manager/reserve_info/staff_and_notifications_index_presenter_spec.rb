require "rails_helper"

RSpec.describe Manager::ReserveInfo::StaffAndNotificationsIndexPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::StaffAndNotificationsIndexPresenter.new(reserve: build(:reserve)) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
  end

end
