require "rails_helper"

RSpec.describe AmenityPresenter do
  describe "delegations" do
    subject { AmenityPresenter.new(build(:amenity)) }
    it { is_expected.to delegate_method(:id).to(:amenity) }
  end

  describe "#title" do
    it "gets the description" do
      amenity = build(:amenity, description: "Some bit of descriptive text")

      presenter = AmenityPresenter.new(amenity)

      expect(presenter.title).to eq "Some bit of descriptive text"
    end
  end
end
