require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveAddendumNewPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::ReserveAddendumNewPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:reserve_addendum).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents ReserveAddendumForm through the presenter" do
      reserve_addendum = create(:reserve_addendum)
      form = ReserveAddendumForm.new(reserve_addendum: reserve_addendum)
      presenter = Manager::ReserveInfo::ReserveAddendumNewPresenter.new(form: form)

      expect(presenter.form).to be_a ReserveAddendumForm
    end
  end
end
