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
      create(:visit)
      form = UserVisitForm.new(params: { id: create(:user_visit).id })
      presenter = Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.editing_user_visit).to be_instance_of Visits::UserVisitPresenter
    end
  end

  describe "#user_days_partial" do
    it "returns empty partial path from shared directory" do
      form = UserVisitForm.new(params: { id: create(:user_visit).id })
      presenter = Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.user_days_partial).to eq "/shared/empty"
    end
  end

  describe "#user_visit_form_path" do
    it "returns user_visit_path" do
      user_visit = create(:user_visit, visit: create(:visit))
      form = UserVisitForm.new(params: { id: user_visit.id })
      presenter = Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.user_visit_form_path).to eq "/user_visits/#{user_visit.id}"
    end
  end

  describe "#institution_form_presenter" do
    it "returns InstitutionFormPresenter object" do
      user_visit = create(:user_visit, visit: create(:visit))
      form = UserVisitForm.new(params: { id: user_visit.id })
      presenter = Visits::UserVisitEditPresenter.new(form: form)
      institution_form_presenter = InstitutionFormPresenter.new(form.institution_form)

      expect(presenter.institution_form_presenter.form).to eq institution_form_presenter.form
    end
  end

  describe "#institution_fields_path" do
    it "returns 'modals/institution_fields/institution_fields' when display_institution_form is true" do
      user_visit = create(:user_visit, visit: create(:visit))
      form = UserVisitForm.new(params: { id: user_visit.id })
      presenter = Visits::UserVisitEditPresenter.new(form: form, display_institution_form: true)

      expect(presenter.institution_fields_path).to eq "modals/institution_fields/institution_fields"
    end

    it "returns 'modals/institution_fields/institution_search_field' when display_institution_form is false" do
      user_visit = create(:user_visit, visit: create(:visit))
      form = UserVisitForm.new(params: { id: user_visit.id })
      presenter = Visits::UserVisitEditPresenter.new(form: form, display_institution_form: false)

      expect(presenter.institution_fields_path).to eq "modals/institution_fields/institution_search_field"
    end
  end
end
