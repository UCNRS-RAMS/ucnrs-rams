# frozen_string_literal: true

require "rails_helper"

RSpec.describe AmenityRatesForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:amenity) }
    it { is_expected.to delegate_method(:validate).to(:amenity) }
    it { is_expected.to delegate_method(:errors).to(:amenity) }
    it { is_expected.to delegate_missing_methods_to(:amenity) }
  end

  describe "initializing" do
    it "loads an existing amenity into AmenityRatesForm from given amenity" do
      amenity = create(:amenity, title: "title 1")
      form = AmenityRatesForm.new(amenity: amenity)

      expect(form).to have_attributes(id: amenity.id, title: "title 1")
    end

    context "when an amenity and params is given" do
      it "overwrites the given amenity_rate attributes with the given params" do
        amenity = create(:amenity)
        amenity_rate = create(:amenity_rate, amenity: amenity, rate: 100)
        form = AmenityRatesForm.new(
          amenity: amenity, 
          params: { amenity_rates_attributes: { "0"=> { rate: 1.0, id: amenity_rate.id } } }
        )

        expect(amenity_rate).to have_attributes(rate: 1.0)
      end
    end
  end

  describe "#save" do
    it "saves the amenity_rate if there are no errors" do
      reserve = create(:reserve)
      amenity = create(:amenity, reserve: reserve)
      amenity_rate_category = create(:amenity_rate_category, reserve: reserve)
      amenity_rate = create(:amenity_rate, rate: 100, amenity: amenity, amenity_rate_category: amenity_rate_category)
      form = AmenityRatesForm.new(
        amenity: amenity, 
        params: { amenity_rates_attributes: { "0"=> { rate: 1.0, id: amenity_rate.id } } }
      )

      result = form.save

      expect(result).to be_truthy
      expect(form.amenity).to be_persisted
      expect(form.amenity).to have_attributes(id: amenity.id)
      expect(amenity_rate).to have_attributes(rate: 1.0)
    end

    it "makes sure errors are visible when save fails" do
      amenity = create(:amenity)
      amenity_rate = create(:amenity_rate, amenity: amenity, rate: 100)
      form = AmenityRatesForm.new(
        amenity: amenity, 
        params: { amenity_rates_attributes: { "0"=> { rate: nil, id: amenity_rate.id } } }
      )

      result = form.save

      expect(result).to be_falsy
      expect(form.errors).to be_present
    end
  end
end
