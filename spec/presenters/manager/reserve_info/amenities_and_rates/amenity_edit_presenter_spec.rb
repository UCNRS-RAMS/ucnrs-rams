require "rails_helper"

RSpec.describe Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: :form) }
    it { is_expected.to delegate_method(:amenity).to(:form).with_prefix(true) }
  end

  describe "#form" do
    it "presents AmenityForm through the presenter" do
      amenity = create(:amenity)
      form = AmenityForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      expect(presenter.form).to be_a AmenityForm
    end
  end

  describe "#units_type_options" do
    it "is an array of units type options" do
      amenity = create(:amenity)
      form = AmenityForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      units_type_options = presenter.units_type_options

      expect(units_type_options.to_a).to match_array [
        ["Per Unit","unit"],
        ["Per Session","session"],
        ["Per Use","use"],
        ["Per Person","person"],
        ["Per Mile","mile"],
        ["Per Square Foot","square_foot"],
        ["Per Facility","facility"],
      ]
    end
  end

  describe "#time_type_options" do
    it "is an array of time type options" do
      amenity = create(:amenity)
      form = AmenityForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      time_type_options = presenter.time_type_options

      expect(time_type_options.to_a).to match_array [
        ["Per Hours","hour"],
        ["Per Day","day"],
        ["Per Night","night"],
        ["Per Week","week"],
        ["Per Month","month"],
        ["Per Quarter","quarter"],
        ["Semi-Annual","semi_annual"],
        ["Per Year","year"],
        ["Per Four Hours","four_hours"],
        ["Per Eight Hours","eight_hours"],
        ["Each","each"],
      ]
    end
  end

  describe "#amenities_type_options" do
    it "is an array of amenities type options" do
      amenity = create(:amenity)
      form = AmenityForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      amenities_type_options = presenter.amenities_type_options

      expect(amenities_type_options.to_a).to match_array [
        ["Housing & Camping","housing_and_camping"], 
        ["Classroom & Meeting Space","classroom_and_meeting_space"], 
        ["Laboratory & Storage Space","laboratory_and_storage_space"], 
        ["Vehicles & Boats","vehicles_and_boats"], 
        ["Other Amenity","other_amenity"], 
      ]
    end
  end
end
