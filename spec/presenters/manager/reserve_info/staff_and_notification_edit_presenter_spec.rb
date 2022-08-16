require "rails_helper"

RSpec.describe Manager::ReserveInfo::StaffAndNotificationEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::StaffAndNotificationEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:reserve_personnel).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents ReservePersonnelForm through the presenter" do
      reserve_personnel = create(:reserve_personnel)
      form = ReservePersonnelForm.new(reserve_personnel: reserve_personnel)
      presenter = Manager::ReserveInfo::StaffAndNotificationEditPresenter.new(form: form)

      expect(presenter.form).to be_a ReservePersonnelForm
    end
  end

  describe "editing_reserve_personnel" do
    it "returns a ReservePersonnelPresenter from the id on the form" do
      first = create(:project_team_membership)
      second = create(:project_team_membership)
      form = ReservePersonnelForm.new(reserve_personnel: second)
      presenter = Manager::ReserveInfo::StaffAndNotificationEditPresenter.new(form: form)

      result = presenter.editing_reserve_personnel

      expect(result).to be_a ReservePersonnelPresenter
      expect(result.id).to eq second.id
    end
  end

  describe "reserve_personnel_id" do
    it "returns the id of the reserve personnel" do
      personnel = create(:reserve_personnel)
      form = ReservePersonnelForm.new(reserve_personnel: personnel)
      presenter = Manager::ReserveInfo::StaffAndNotificationEditPresenter.new(form: form)

      expect(presenter.reserve_personnel_id).to eq personnel.id
    end
  end

  describe "reserve_personnel_name" do
    it "returns the name of the user based on the reserve_personnel" do
      personnel = create(
        :reserve_personnel,
        user: create(:user, first_name: "First", last_name: "Last")
      )
      form = ReservePersonnelForm.new(reserve_personnel: personnel)
      presenter = Manager::ReserveInfo::StaffAndNotificationEditPresenter.new(form: form)

      expect(presenter.reserve_personnel_name).to eq "First Last"
    end
  end
end
