require "rails_helper"

RSpec.describe InstitutionPresenter do
  describe "delegations" do
    subject { InstitutionPresenter.new(build(:institution)) }
    it { is_expected.to delegate_method(:id).to(:institution) }
    it { is_expected.to delegate_method(:name).to(:institution) }
    it { is_expected.to delegate_method(:city).to(:institution) }
    it { is_expected.to delegate_method(:country).to(:institution) }
  end

  describe "#country_name" do
    it "presents institution country name correctly through the presenter" do
      country = create(:country, name: "Two Rivers")
      institution = create(:institution, name: "TR College", country: country)

      presenter = InstitutionPresenter.new(institution)

      expect(presenter.country_name).to eq country.name
    end
  end
end
