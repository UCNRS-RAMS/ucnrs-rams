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

  describe ".at_reserve" do
    it "returns amenity visits from the given reserve" do
      reserve1 = create(:reserve)
      reserve2 = create(:reserve)
      visit1 = create(:visit, reserve: reserve1)
      visit2 = create(:visit, reserve: reserve2)
      amenity_visit1 = create(:amenity_visit, visit: visit1)
      amenity_visit2 = create(:amenity_visit, visit: visit2)
      amenity_visit3 = create(:amenity_visit, visit: visit1)

      results = AmenityVisit.at_reserve(reserve1)

      expect(results).to eq [amenity_visit1, amenity_visit3]
    end
  end

  describe ".on_date" do
    it "returns amenity visits with a given date on/or between the arrives_at and departs_at dates" do
      visit = create(:visit, starts_at: 3.week.ago, ends_at: 3.week.from_now)
      amenity_visit1 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.week.from_now)
      amenity_visit2 = create(:amenity_visit, visit: visit, arrives: Time.current, departs:Time.current)
      amenity_visit3 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: Time.current)
      amenity_visit4 = create(:amenity_visit, visit: visit, arrives: Time.current, departs: 1.day.from_now)
      amenity_visit5 = create(:amenity_visit, visit: visit, arrives: 1.week.ago, departs: 1.day.ago)

      results = AmenityVisit.on_date(Date.current)

      expect(results).to eq [amenity_visit1, amenity_visit2, amenity_visit3, amenity_visit4]
    end
  end
end
