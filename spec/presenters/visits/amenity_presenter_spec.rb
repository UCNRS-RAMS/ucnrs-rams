require "rails_helper"

RSpec.describe Visits::AmenityPresenter do
  describe "delegations to amenity" do
    subject { Visits::AmenityPresenter.new(build(:amenity)) }
    it { is_expected.to delegate_method(:title).to(:amenity) }
    it { is_expected.to delegate_method(:description).to(:amenity) }
    it { is_expected.to delegate_method(:image_url).to(:amenity) }
    it { is_expected.to delegate_method(:unit).to(:amenity).as(:units_type) }
    it { is_expected.to delegate_method(:period).to(:amenity).as(:time_type) }
  end

  describe "delegations to form" do
    subject { Visits::AmenityPresenter.new(nil, form: AmenityForm.new) }
    it { is_expected.to delegate_method(:arrives_on).to(:form) }
    it { is_expected.to delegate_method(:departs_on).to(:form) }
    it { is_expected.to delegate_method(:number_of_people).to(:form) }
    it { is_expected.to delegate_method(:checked).to(:form) }
  end

  describe "#rates" do
    it "presents its rates in order" do
      amenity = Visits::AmenityPresenter.new(create(:amenity))
      rates = [
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 1),
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 3),
        create(:amenity_rate, amenity: amenity.amenity, sort_order: 2),
      ]

      presented_rates = amenity.rates

      expect(presented_rates.map(&:id))
        .to eq [rates[0].id, rates[2].id, rates[1].id]
    end
  end
end
