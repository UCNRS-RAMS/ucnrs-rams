require "rails_helper"

RSpec.describe Manager::ReserveInfo::WaiverEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::WaiverEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:waiver).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents WaiverForm through the presenter" do
      waiver = create(:waiver)
      form = WaiverForm.new(waiver: waiver)
      presenter = Manager::ReserveInfo::WaiverEditPresenter.new(form: form)

      expect(presenter.form).to be_a WaiverForm
    end
  end
end
