require "rails_helper"

RSpec.describe Manager::ReserveInfo::PermitEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::PermitEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:reserve_permit).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents ReservePermitForm through the presenter" do
      reserve_permit = create(:reserve_permit)
      form = ReservePermitForm.new(reserve_permit: reserve_permit)
      presenter = Manager::ReserveInfo::PermitEditPresenter.new(form: form)

      expect(presenter.form).to be_a ReservePermitForm
    end
  end

  describe "#permit_question" do
    it "return the permit question" do
      permit = create(:permit, question: "Is the Earth round?")
      reserve_permit = create(:reserve_permit, permit: permit)
      form = ReservePermitForm.new(reserve_permit: reserve_permit)
      presenter = Manager::ReserveInfo::PermitEditPresenter.new(form: form)

      permit_question = presenter.permit_question

      expect(permit_question).to eq "Is the Earth round?"
    end
  end

  describe "#permit_description" do
    it "is an array of location options" do
      permit = create(:permit, description: "permit description")
      reserve_permit = create(:reserve_permit, permit: permit)
      form = ReservePermitForm.new(reserve_permit: reserve_permit)
      presenter = Manager::ReserveInfo::PermitEditPresenter.new(form: form)

      permit_description = presenter.permit_description

      expect(permit_description).to eq "permit description"
    end
  end
end
