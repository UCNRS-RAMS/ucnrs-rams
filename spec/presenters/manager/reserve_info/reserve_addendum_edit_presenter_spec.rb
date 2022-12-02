require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveAddendumEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::ReserveAddendumEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:reserve_addendum).to(:form).with_prefix(true) }
    it { is_expected.to delegate_method(:id).to(:form_reserve_addendum).with_prefix(:reserve_addendum) }
  end

  describe "#form" do
    it "presents ReserveAddendumForm through the presenter" do
      reserve_addendum = create(:reserve_addendum)
      form = ReserveAddendumForm.new(reserve_addendum: reserve_addendum)
      presenter = Manager::ReserveInfo::ReserveAddendumEditPresenter.new(form: form)

      expect(presenter.form).to be_a ReserveAddendumForm
    end
  end
end
