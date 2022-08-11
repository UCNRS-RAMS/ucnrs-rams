require "rails_helper"

RSpec.describe Manager::ReserveInfo::AmenitiesAndRates::AmenityRateCategoryEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::AmenitiesAndRates::AmenityRateCategoryEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:amenity_rate_category).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents AmenityRateCategoryForm through the presenter" do
      amenity_rate_category = create(:amenity_rate_category)
      form = AmenityRateCategoryForm.new(amenity_rate_category: amenity_rate_category)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityRateCategoryEditPresenter.new(form: form)

      expect(presenter.form).to be_a AmenityRateCategoryForm
    end
  end
end
