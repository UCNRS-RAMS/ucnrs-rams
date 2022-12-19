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
      allow(Amenity).to receive(:units_types).and_return(
        {
          "units_type_1_key" => "units_type_1",
          "units_type_2_key" => "units_type_2",
        }
      )
      allow(I18n).to receive(:t)
        .with("universal.amenity.units_types.units_type_1_key")
        .and_return("units_type_1_key_translate")
      allow(I18n).to receive(:t)
        .with("universal.amenity.units_types.units_type_2_key")
        .and_return("units_type_2_key_translate")
      form = AmenityForm.new
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      units_type_options = presenter.units_type_options

      expect(units_type_options.to_a).to match_array [
        ["units_type_1_key_translate", "units_type_1_key"],
        ["units_type_2_key_translate", "units_type_2_key"],
      ]
    end
  end

  describe "#time_type_options" do
    it "is an array of time type options" do
      allow(Amenity).to receive(:time_types).and_return(
        {
          "time_type_1_key" => "time_type_1",
          "time_type_2_key" => "time_type_2",
        }
      )
      allow(I18n).to receive(:t)
        .with("universal.amenity.time_types.time_type_1_key")
        .and_return("time_type_1_key_translate")
      allow(I18n).to receive(:t)
        .with("universal.amenity.time_types.time_type_2_key")
        .and_return("time_type_2_key_translate")
      form = AmenityForm.new
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      time_type_options = presenter.time_type_options

      expect(time_type_options.to_a).to match_array [
        ["time_type_1_key_translate", "time_type_1_key"],
        ["time_type_2_key_translate", "time_type_2_key"],
      ]
    end
  end

  describe "#amenities_group_options" do
    it "is an array of time type options" do
      reserve = create(:reserve,
        amenity_group_label_1: "Label 1",
        amenity_group_label_2: "Label 2",
        amenity_group_label_3: "Label 3",
        amenity_group_label_4: "Label 4",
        amenity_group_label_5: "Label 5"
      )
      amenity = create(:amenity, reserve: reserve)
      form = AmenityForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      time_type_options = presenter.amenities_group_options

      expect(time_type_options.to_a).to match_array [
        ["Label 1", "1"],
        ["Label 2", "2"],
        ["Label 3", "3"],
        ["Label 4", "4"],
        ["Label 5", "5"],
      ]
    end
  end

  describe "#listing_photo" do
    it "presents placeholder image if no listing_photo is attached" do
      amenity = build(:amenity)
      form = AmenityForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      expect(presenter.listing_photo).to eq("amenity_placeholder.jpg")
    end

    it "presents the correct avatar path if listing_photo is attached" do
      amenity = create(:amenity, :with_listing_photo)
      form = AmenityForm.new(amenity: amenity)
      presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityEditPresenter.new(form: form)

      expect(presenter.listing_photo).to match(
        /\/medium_test-image.jpeg/
      )
    end
  end
end
