require "rails_helper"

RSpec.describe Visits::UserVisitEditPresenter do
  describe "delegations" do
    subject do
      form = UserVisitForm.new(params: { id: create(:user_visit).id })
      Visits::UserVisitEditPresenter.new(form: form)
    end

    it { is_expected.to delegate_method(:id).to(:form) }
    it { is_expected.to delegate_method(:errors).to(:form) }
    it { is_expected.to delegate_missing_methods_to(:editing_user_visit) }
  end

  describe "#editing_user_visit" do
    it "return Visits::UserVisitPresenter" do
      form = UserVisitForm.new(params: { id: create(:user_visit).id })
      presenter = Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.editing_user_visit).to be_instance_of Visits::UserVisitPresenter
    end
  end

  describe "#user_visit_form_path" do
    it "returns user_visit_path" do
      user_visit = create(:user_visit)
      form = UserVisitForm.new(params: { id: user_visit.id })
      presenter = Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.user_visit_form_path).to eq "/user_visits/#{user_visit.id}"
    end
  end
end
