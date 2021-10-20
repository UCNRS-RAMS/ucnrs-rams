require "rails_helper"

RSpec.describe AmenityForm do
  describe "initializing" do
    it "makes a new AmenityVisit from params" do
      amenity = create(:amenity)
      params = {
        amenity_id: amenity.id,
      }
      form = AmenityForm.new(params)

      expect(form.amenity_visit).to have_attributes(
        amenity_id: amenity.id,
      )
    end

    it "assigns the dates through accessors" do
      arrival = "2020-10-13"
      departure = "2021-01-02"
      params = {
        arrives_on: arrival,
        departs_on: departure,
      }
      form = AmenityForm.new(params)

      expect(form.amenity_visit).to have_attributes(
        arrives_on: Date.new(2020, 10, 13),
        departs_on: Date.new(2021, 1, 2),
      )
    end
  end

  describe "date presentation" do
    it "shows the date in m/d/y format" do
      arrival = "2020-10-13"
      departure = "2021-1-2"
      params = {
        arrives_on: arrival,
        departs_on: departure,
      }
      form = AmenityForm.new(params)

      expect(form.arrives_on).to eq "2020-10-13"
      expect(form.departs_on).to eq "2021-01-02"
    end
  end

  describe "#checked" do
    it "is 'checked' if there is an amenity_id" do
      form = AmenityForm.new(amenity_id: 1)

      expect(form.checked).to eq "checked"
    end

    it "is nil if there is no amenity_id" do
      form = AmenityForm.new({})

      expect(form.checked).to be_nil
    end
  end
end
