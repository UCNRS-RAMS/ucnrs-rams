require "rails_helper"

RSpec.describe Manager::InstitutionEditPresenter do
  describe "delegations" do
    subject { Manager::InstitutionEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:institution).to(:form).with_prefix(true) }
    it { is_expected.to delegate_method(:id).to(:form_institution).with_prefix(:institution) }
    it { is_expected.to delegate_method(:name).to(:form_institution).with_prefix(:institution) }
  end

  describe "#form" do
    it "presents InstitutionEditForm through the presenter" do
      institution = create(:institution)
      form = InstitutionEditForm.new(institution: institution)
      presenter = Manager::InstitutionEditPresenter.new(form: form)

      expect(presenter.form).to be_a InstitutionEditForm
    end
  end

  describe "#institution_type_options" do
    it "is an array of institution type options translated" do
      allow(Institution).to receive(:institution_types).and_return(
        {
          "institution_type_1_key" => "institution_type_1",
          "institution_type_2_key" => "institution_type_2",
        }
      )
      allow(I18n).to receive(:t)
        .with("universal.institution_types.institution_type_1_key")
        .and_return("institution_type_1_key_translate")
      allow(I18n).to receive(:t)
        .with("universal.institution_types.institution_type_2_key")
        .and_return("institution_type_2_key_translate")
      presenter = Manager::InstitutionEditPresenter.new(form: nil)

      institution_type_options = presenter.institution_type_options

      expect(institution_type_options.to_a).to match_array [
        ["institution_type_1_key_translate", "institution_type_1_key"],
        ["institution_type_2_key_translate", "institution_type_2_key"],
      ]
    end
  end

  describe "#institution_country_options" do
    it "is an array of institution type options translated" do
      country1 = create(:country, name: "d")
      country2 = create(:country, name: "a")
      country3 = create(:country, name: "z")
      presenter = Manager::InstitutionEditPresenter.new(form: nil)

      institution_country_options = presenter.institution_country_options

      expect(institution_country_options).to eq [
        ["a", country2.id],
        ["d", country1.id],
        ["z", country3.id],
      ]
    end
  end

  describe "#institution_state_options" do
    it "is an array of institution type options translated" do
      state1 = create(:state, name: "d")
      state2 = create(:state, name: "a")
      state3 = create(:state, name: "z")
      presenter = Manager::InstitutionEditPresenter.new(form: nil)

      institution_state_options = presenter.institution_state_options

      expect(institution_state_options).to eq [
        ["a", state2.id],
        ["d", state1.id],
        ["z", state3.id],
      ]
    end
  end
end
