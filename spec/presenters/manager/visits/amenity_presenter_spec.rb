require "rails_helper"

RSpec.describe Manager::Visits::AmenityPresenter do
  let(:amenity_presenter) { Manager::Visits::AmenityPresenter.new(build(:amenity)) }

  describe "#amenity_rate_partial_path" do
    it "should return 'manager/visits/detail/amenity_rate'" do
      expect(amenity_presenter.amenity_rate_partial_path).to eq "manager/visits/detail/amenity_rate"
    end
  end
end
