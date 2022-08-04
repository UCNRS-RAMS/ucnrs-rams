require "rails_helper"

RSpec.describe VisitForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
  end

  describe "aliases" do
    it "aliases VisitForm#validate to VisitForm#valid?" do
      validate = VisitForm.instance_method(:validate)
      expect(VisitForm.instance_method(:valid?)).to eq validate
    end
  end

  describe "initializing" do
    it "makes an empty VisitForm from empty params" do
      form = VisitForm.new

      expect(form).to have_attributes(
        project_type: nil,
        project_id: nil,
        public_use_category: "general_use",
        purpose_of_visit: nil,
        reserve_id: nil,
        start_date: "",
        start_time: "12:00",
        end_date: "",
        end_time: "12:00",
        special_needs: nil,
      )
    end

    it "makes a new VisitForm from params" do
      params = {
        project_type: "public_use",
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
        project_type: "public_use",
        project_id: 101,
        public_use_category: "k_12_class",
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

  describe "assigning project_type" do
    it "sets the project_id to nil" do
      form = VisitForm.new

      form.project_type = :research

      expect(form.project_id).to be_nil
    end
  end

  describe "assigning amenities" do
    it "returns an Visits::AmenityForm for each amenity_id" do
      params = {
        amenities: {
          1 => {
            amenity_id: 1,
            amenity_visits: {
              1 => {
                arrives_on: nil,
                departs_on: nil,
                number_of_people: nil,
                amenity_rate_id: 1,
              },
            },
          },
          101 => {
            amenity_id: 101,
            amenity_visits: {
              1 => {
                arrives_on: nil,
                departs_on: nil,
                number_of_people: nil,
                amenity_rate_id: 1,
              },
            },
          },
        },
      }
      form = VisitForm.new(user: build(:user), params: params)

      expect(form.amenity_form("1").first).to be_a(Visits::AmenityForm)
      expect(form.amenity_form("1").first.amenity_id).to eq 1
      expect(form.amenity_form("101").first).to be_a(Visits::AmenityForm)
      expect(form.amenity_form("101").first.amenity_id).to eq 101
    end
  end

  describe "#validate" do
    it "has no errors if everything is happy" do
      project = create(:project)
      reserve = create(:reserve)
      user = create(:user)
      form = VisitForm.new(user: user, params: {
        project: project,
        reserve: reserve,
        purpose_of_visit: "Nothing",
        project_type: :research,
        start_date: 1.day.from_now.strftime("%Y-%m-%d"),
        end_date: 2.days.from_now.strftime("%Y-%m-%d"),
        start_time: "15:00",
        end_time: "17:00",
      })

      form.validate

      expect(form.errors).to be_blank
    end

    it "gets errors from itself and the visit (but not amenities)" do
      project = create(:project)
      reserve = create(:reserve, amenities_named: ["one", "two"])
      one, two = reserve.amenities
      user = create(:user)
      form = VisitForm.new(user: user, params: {
        project: project,
        reserve: reserve,
        purpose_of_visit: nil,
        project_type: nil,
        start_date: nil,
        end_date: nil,
        amenities: {
          one.id.to_s => {
            amenity_id: one.id,
            amenity_visits: {
              "1": {
                arrives_on: nil,
                departs_on: nil,
                number_of_people: nil,
                amenity_rate_id: one.amenity_rates.first.id,
              },
            },
          },
        }
      })

      form.validate

      expect(form.errors.to_hash).to eq({
        purpose_of_visit: ["can't be blank"],
        project_type: ["can't be blank"],
        start_date: ["can't be blank"],
        end_date: ["can't be blank"],
        start_time: ["can't be blank"],
        end_time: ["can't be blank"],
      })
    end
  end

  describe "#save" do
    it "saves both the Visit and the Amenities if there are no errors" do
      project = create(:project)
      reserve = create(:reserve, amenities_named: ["one", "two"])
      one, two = reserve.amenities
      user = create(:user)
      form = VisitForm.new(user: user, params: {
        project_id: project.id,
        reserve_id: reserve.id,
        purpose_of_visit: "Nothing",
        project_type: "research",
        start_date: 1.week.from_now.strftime("%Y-%m-%d"),
        end_date: 2.weeks.from_now.strftime("%Y-%m-%d"),
        start_time: "15:00",
        end_time: "16:00",
        amenities: {
          one.id.to_s => {
            amenity_id: one.id.to_s,
            amenity_rate_id: one.amenity_rates.first.id,
            amenity_visits: {
              "1": {
                arrives_on: 1.weeks.from_now.strftime("%Y-%m-%d"),
                departs_on: 2.week.from_now.strftime("%Y-%m-%d"),
                number_of_people: 2,
                amenity_rate_id: one.amenity_rates.first.id,
              },
            },
          },
        },
      })

      result = form.save
      expect(result).to be_truthy
      expect(form.visit).to be_persisted
      form.visit.amenity_visits.each do |amenity_visit|
        expect(amenity_visit).to be_persisted
      end
    end

    it "makes sure all errors are visible when save fails" do
      project = create(:project)
      reserve = create(:reserve, amenities_named: ["one", "two"])
      one, two = reserve.amenities
      user = create(:user)
      form = VisitForm.new(user: user, params: {
        project_id: project.id,
        reserve_id: reserve.id,
        purpose_of_visit: nil,
        project_type: "research",
        start_date: 1.week.from_now.strftime("%Y-%m-%d"),
        end_date: 2.weeks.from_now.strftime("%Y-%m-%d"),
        amenities: {
          one.id.to_s => {
            amenity_id: one.id.to_s,
            amenity_visits: {
              "1": {
                arrives_on: 2.weeks.from_now.strftime("%Y-%m-%d"),
                departs_on: 1.week.from_now.strftime("%Y-%m-%d"),
                number_of_people: 2,
                amenity_rate_id: one.amenity_rates.first.id,
              },
            },
          },
        },
      })

      result = form.save

      expect(result).to be_falsy
      expect(form.visit).to_not be_persisted
      expect(form.errors).to be_present
      expect(form.amenity_form(one.id.to_s).first.errors).to be_present
    end
  end

  describe "#parse_date" do
    it "parses a date in %Y-%m-%d format" do
      form = VisitForm.new

      form.start_date = "1999-2-1"

      visit_start_date = form.visit.start_date
      expect(visit_start_date.year).to eq 1999
      expect(visit_start_date.month).to eq 2
      expect(visit_start_date.day).to eq 1
    end

    it "returns nil if there is an error in parsing the date" do
      form = VisitForm.new

      form.start_date = "CHRISTMAS!"

      visit_start_date = form.visit.start_date
      expect(visit_start_date).to be_nil
    end
  end

  describe "#parse_time" do
    it "parses a time in %H:%M format" do
      form = VisitForm.new

      form.start_time = "15:51"

      visit_start_time = form.visit.start_time
      expect(visit_start_time.hour).to eq 15
      expect(visit_start_time.min).to eq 51
    end

    it "returns nil if there is an error in parsing the time" do
      form = VisitForm.new

      form.start_time = "Midnight"

      visit_start_time = form.visit.start_time
      expect(visit_start_time).to be_nil
    end
  end
end
