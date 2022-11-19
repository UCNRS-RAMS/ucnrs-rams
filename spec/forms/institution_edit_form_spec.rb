require "rails_helper"

RSpec.describe InstitutionEditForm do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:institution) }
    it { is_expected.to delegate_method(:errors).to(:institution) }
    it { is_expected.to delegate_missing_methods_to(:institution) }
  end

  describe "initializing" do
    it "makes a new empty InstitutionEditForm" do
      form = InstitutionEditForm.new()

      expect(form).to have_attributes(
        id: nil,
        managing_institution_id: 0,
        name: nil,
        city: nil,
        state_id: nil,
        country_id: nil,
        institution_type: nil,
        acronym: nil,
        doi: "0000",
      )
    end

    it "makes a new InstitutionEditForm from params" do
      params = {
        id: 5,
        managing_institution_id: 5,
        name: "institution name",
        city: "institution city",
        state_id: 5,
        country_id: 5,
        institution_type: :university_of_california,
        acronym: "inst",
        doi: "1111",
      }
      form = InstitutionEditForm.new(params: params)

      expect(form).to have_attributes(
        id: 5,
        managing_institution_id: 5,
        name: "institution name",
        city: "institution city",
        state_id: 5,
        country_id: 5,
        institution_type: "university_of_california",
        acronym: "inst",
        doi: "1111",
      )
    end

    it "loads an existing institution into InstitutionEditForm from given institution" do
      institution = create(:institution, name: "name1")
      form = InstitutionEditForm.new(institution: institution)

      expect(form).to have_attributes(id: institution.id, name: "name1")
    end

    context "when a institution and params is given" do
      it "overwrites the given institution attributes with the given params" do
        institution = create(:institution, name: "name old")
        form = InstitutionEditForm.new(institution: institution, params: { name: "name new" })

        expect(form).to have_attributes(id: institution.id, name: "name new")
      end
    end
  end

  describe "#submit" do
    it "saves the institution if there are no errors" do
      institution = create(:institution, name: "name old")
      form = InstitutionEditForm.new(institution: institution, params: { name: "name new" })

      result = form.submit

      expect(result).to be_truthy
      expect(form.institution).to be_persisted
      expect(form.institution).to have_attributes(id: institution.id, name: "name new")
    end

    it "makes sure errors are visible when submit fails" do
      form = InstitutionEditForm.new()

      result = form.submit

      expect(result).to be_falsy
      expect(form.institution).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
