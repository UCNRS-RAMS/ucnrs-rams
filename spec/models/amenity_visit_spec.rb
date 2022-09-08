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

  describe "#calc_units_of_time" do
    it "calculate the units of time through num_of_units helper" do
      amenity_visit = create(:amenity_visit)
      allow(ApplicationController.helpers).to receive(:num_of_units)

      amenity_visit.calc_units_of_time

      expect(ApplicationController.helpers).to have_received(:num_of_units)
    end
  end

  describe "#real_units_of_time" do
    context "when manual_units_of_time is zero/blank" do
      it "returns calc_units_of_time" do
        amenity_visit = create(:amenity_visit, manual_units_of_time: 0)
        allow(ApplicationController.helpers).to receive(:num_of_units)

        amenity_visit.real_units_of_time

        expect(ApplicationController.helpers).to have_received(:num_of_units)
      end
    end

    context "when manual_units_of_time is not zero/blank" do
      it "returns manual_units_of_time" do
        amenity_visit = create(:amenity_visit, manual_units_of_time: 10)

        expect(amenity_visit.real_units_of_time).to eq 10
      end
    end
  end

  it do
    is_expected.to define_enum_for(:status)
      .with_values(
        approved: "Approved",
        in_review: "Pending approval",
        cancelled: "Cancelled",
        denied: "Rejected",
      ).backed_by_column_of_type(:string)
  end

  describe "#subtotal" do
    it "multiplies and return number_of_people * real_units_of_time * rate" do
      amenity_visit = create(:amenity_visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)

      expect(amenity_visit.subtotal).to eq 1000
    end
  end
end
