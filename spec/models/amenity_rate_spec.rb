require "rails_helper"

RSpec.describe AmenityRate, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:amenity) }
    it { is_expected.to belong_to(:amenity_rate_category) }
  end
end
