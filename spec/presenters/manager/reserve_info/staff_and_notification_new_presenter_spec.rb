require "rails_helper"

RSpec.describe Manager::ReserveInfo::StaffAndNotificationNewPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::StaffAndNotificationNewPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:reserve_personnel).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents ReservePersonnelForm through the presenter" do
      reserve_personnel = create(:reserve_personnel)
      form = ReservePersonnelForm.new(reserve_personnel: reserve_personnel)
      presenter = Manager::ReserveInfo::StaffAndNotificationNewPresenter.new(form: form)

      expect(presenter.form).to be_a ReservePersonnelForm
    end
  end
end
