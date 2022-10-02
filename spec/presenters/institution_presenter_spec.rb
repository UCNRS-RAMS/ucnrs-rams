require "rails_helper"

RSpec.describe InstitutionPresenter do
  describe "delegations" do
    subject { InstitutionPresenter.new(build(:institution)) }
    it { is_expected.to delegate_method(:id).to(:institution) }
    it { is_expected.to delegate_method(:name).to(:institution) }
    it { is_expected.to delegate_method(:city).to(:institution) }
    it { is_expected.to delegate_method(:country).to(:institution) }
    it { is_expected.to delegate_method(:institution_type).to(:institution) }
  end

  describe "#country_name" do
    it "presents institution country name correctly through the presenter" do
      country = create(:country, name: "Two Rivers")
      institution = create(:institution, name: "TR College", country: country)
      presenter = InstitutionPresenter.new(institution)

      country_name = presenter.country_name

      expect(country_name).to eq "Two Rivers"
    end
  end

  describe "#state_name" do
    it "presents institution state name correctly through the presenter" do
      state = create(:state, name: "walachia")
      institution = create(:institution, name: "TR College", state: state)
      presenter = InstitutionPresenter.new(institution)

      state_name = presenter.state_name

      expect(state_name).to eq "walachia"
    end
  end

  describe "#address_line_3" do
    context "when state is present" do
      it "correctly presents city, state and country correctly" do
        state = create(:state, name: "Walachia")
        country = create(:country, name: "Two Rivers")
        institution = create(:institution, name: "TR College", city: "Wygol", state: state, country: country)
        presenter = InstitutionPresenter.new(institution)

        address_line_3 = presenter.address_line_3

        expect(address_line_3).to eq "Wygol, Walachia, Two Rivers"
      end
    end

    context "when state is NOT present" do
      it "correctly presents city and country correctly" do
        country = create(:country, name: "Two Rivers")
        institution = create(:institution, name: "TR College", city: "Wygol", state: nil, country: country)
        presenter = InstitutionPresenter.new(institution)

        address_line_3 = presenter.address_line_3

        expect(address_line_3).to eq "Wygol, Two Rivers"
      end
    end
  end
end
