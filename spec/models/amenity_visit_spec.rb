require "rails_helper"

RSpec.describe AmenityVisit do
  describe "validations" do
    it { is_expected.to validate_date(:departs_on).is_after(:arrives_on) }
    it { is_expected.to validate_numericality_of(:number_of_people).is_greater_than(0) }
  end

  describe "associations" do
    it {is_expected.to belong_to(:amenity) }
    it {is_expected.to belong_to(:amenity_rate) }
    it {is_expected.to belong_to(:user) }
    it {is_expected.to belong_to(:visit) }
  end

  describe "#amenity_visit_id=" do
    it "sets the `id`" do
      amenity_visit = AmenityVisit.new

      amenity_visit.amenity_visit_id = 2

      expect(amenity_visit.id).to eq 2
    end
  end
end
