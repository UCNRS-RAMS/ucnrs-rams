require "rails_helper"

RSpec.describe VisitForm do
  describe "initializing" do
    it "makes an empty VisitForm from empty params" do
      form = VisitForm.new(user: build(:user), params: {})

      expect(form).to have_attributes(
        project_type: nil,
        project_id: nil,
        public_use_category: "general-use",
        purpose_of_visit: nil,
        reserve_id: nil,
        start_date: "",
        start_time: "",
        end_date: "",
        end_time: "",
        special_needs: nil,
      )
    end

    it "makes a new VisitForm from params" do
      params = {
        project_type: "public-use",
        project_id: 101,
        public_use_category: "k-12-class",
        purpose_of_visit: "World Conquest",
        reserve_id: 102,
        start_date: "2021-7-7",
        start_time: "14:00",
        end_date: "2021-10-26",
        end_time: "15:30",
        special_needs: "A teddy bear",
      }
      form = VisitForm.new(user: build(:user), params: params)

      expect(form).to have_attributes(
        project_type: "public-use",
        project_id: 101,
        public_use_category: "k-12-class",
        purpose_of_visit: "World Conquest",
        reserve_id: 102,
        start_date: "2021-07-07",
        start_time: "14:00",
        end_date: "2021-10-26",
        end_time: "15:30",
        special_needs: "A teddy bear",
      )
    end
  end

  describe "assigning amenities" do
    it "returns an AmenityForm for each amenity_id" do
      params = {
        amenities: {
          1 => {amenity_id: 1},
          101 => {amenity_id: 101},
        }
      }
      form = VisitForm.new(user: build(:user), params: params)

      expect(form.amenity_form("1")).to be_a(AmenityForm)
      expect(form.amenity_form("1").amenity_id).to eq 1
      expect(form.amenity_form("101")).to be_a(AmenityForm)
      expect(form.amenity_form("101").amenity_id).to eq 101
    end
  end
end
