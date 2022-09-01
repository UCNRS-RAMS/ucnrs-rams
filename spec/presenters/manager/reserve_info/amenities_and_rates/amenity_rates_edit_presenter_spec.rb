require "rails_helper"

RSpec.describe Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:amenity).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents AmenityRatesForm through the presenter" do
      amenity = create(:amenity)
      form = AmenityRatesForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesEditPresenter.new(form: form)

      expect(presenter.form).to be_a AmenityRatesForm
    end
  end

  describe "#amenity_name" do
    it "presents amenity title through the presenter" do
      amenity = create(:amenity, title: "Title 1")
      form = AmenityRatesForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesEditPresenter.new(form: form)

      expect(presenter.amenity_name).to eq "Title 1"
    end
  end

  describe "#amenity_rates" do
    it "presents AmenityRatesForm through the presenter" do
      amenity = create(:amenity)
      form = AmenityRatesForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesEditPresenter.new(form: form)

      expect(presenter.form).to be_a AmenityRatesForm
    end
  end
end
