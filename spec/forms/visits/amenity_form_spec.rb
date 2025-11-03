require "rails_helper"

RSpec.describe Visits::AmenityForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:amenity_id) }
    it { is_expected.to validate_presence_of(:arrives_on) }
    it { is_expected.to validate_presence_of(:departs_on) }
  end

  describe "initializing" do
    it "makes a new AmenityVisit from arguments" do
      amenity = create(:amenity)
      user = create(:user)
      params = {
        amenity_id: amenity.id,
      }
      form = Visits::AmenityForm.new(params: params, user: user)

      expect(form.amenity_visit).to have_attributes(
        amenity_id: amenity.id,
        user_id: user.id,
      )
    end

    it "assigns the dates through accessors" do
      arrival_time = "2020-10-13"
      departure_time = "2021-01-02"
      params = {
        arrives_on: arrival_time,
        departs_on: departure_time,
      }
      form = Visits::AmenityForm.new(params: params)

      expect(form.amenity_visit).to have_attributes(
        arrives_on: Date.new(2020, 10, 13),
        departs_on: Date.new(2021, 1, 2),
      )
    end

    context "when the UserVisit is attached to a Visit with a status of 'incomplete'" do
      it "status is set to default" do
        visit = create(:visit, status: :incomplete)
        params = { visit_id: visit.id }
        form = Visits::AmenityForm.new(params: params)

        expect(form.status).to eq(UserVisit.new.status)
      end
    end

    context "when the UserVisit is attached to a Visit with a status that is not 'incomplete'" do
      it "status is set to the same as the Visit status" do
        visit1 = create(:visit, status: :approved)
        visit2 = create(:visit, status: :in_review)
        visit3 = create(:visit, status: :cancelled)
        visit4 = create(:visit, status: :denied)
        form1 = UserVisitForm.new(params: { visit_id: visit1.id })
        form2 = UserVisitForm.new(params: { visit_id: visit2.id })
        form3 = UserVisitForm.new(params: { visit_id: visit3.id })
        form4 = UserVisitForm.new(params: { visit_id: visit4.id })

        expect(form1.status).to eq(visit1.status)
        expect(form2.status).to eq(visit2.status)
        expect(form3.status).to eq(visit3.status)
        expect(form4.status).to eq(visit4.status)
      end
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
      form = Visits::AmenityForm.new(params: params)

      expect(form.arrives_on).to eq "2020-10-13"
      expect(form.departs_on).to eq "2021-01-02"
    end
  end

  describe "#checked" do
    it "is 'checked' if there is an amenity_id" do
      form = Visits::AmenityForm.new(params: { amenity_id: 1 })

      expect(form.checked).to eq "checked"
    end

    it "is nil if there is no amenity_id" do
      form = Visits::AmenityForm.new

      expect(form.checked).to be_nil
    end
  end

  describe "#validate" do
    it "has no errors if everything passes validation" do
      amenity = create(:amenity, rates: [12.34])
      form = Visits::AmenityForm.new(params: {
        amenity_id: amenity.id,
        amenity_rate_id: amenity.amenity_rates.first.id,
        arrives_on: 1.day.from_now.strftime("%Y-%m-%d"),
        departs_on: 2.days.from_now.strftime("%Y-%m-%d"),
        number_of_people: 3,
        user: create(:user),
        visit: create(:visit),
      })

      valid_form = form.validate

      expect(valid_form).to eq true
    end

    it "validates the form and the model and gathers errors" do
      form = Visits::AmenityForm.new

      form.validate

      expect(form.errors.to_hash).to eq ({
        amenity: ["must exist"],
        amenity_id: [I18n.t("activerecord.errors.messages.blank")],
        amenity_rate: ["must exist"],
        arrives_on: [I18n.t("activerecord.errors.messages.blank")],
        departs_on: [I18n.t("activerecord.errors.messages.blank")],
        number_of_people: ["must be a number greater than 0"],
        visit: ["must exist"],
      })
    end
  end

  describe "aliases" do
    it "aliases Visits::AmenityForm#validate to Visits::AmenityForm#valid?" do
      validate = Visits::AmenityForm.instance_method(:validate)
      expect(Visits::AmenityForm.instance_method(:valid?)).to eq validate
    end
  end

  describe "#save" do
    it "persists a valid AmenityVisit to the database" do
      amenity = create(:amenity, rates: [12.34])
      form = Visits::AmenityForm.new(params: {
        amenity_id: amenity.id,
        amenity_rate_id: amenity.amenity_rates.first.id,
        arrives_on: 1.day.from_now.strftime("%Y-%m-%d"),
        departs_on: 2.days.from_now.strftime("%Y-%m-%d"),
        number_of_people: 3,
        user: create(:user),
        visit: create(:visit),
      })

      form.save

      expect(form.amenity_visit).to be_persisted
    end
  end

  describe "#parse_date (implicitly through setters)" do
    it "parses a date in %Y-%m-%d format" do
      form = Visits::AmenityForm.new

      form.arrives_on = "1999-2-1"

      amenity_visit_arrives_on = form.amenity_visit.arrives_on
      expect(amenity_visit_arrives_on.year).to eq 1999
      expect(amenity_visit_arrives_on.month).to eq 2
      expect(amenity_visit_arrives_on.day).to eq 1
    end

    it "returns nil if there is an error in parsing the date" do
      form = Visits::AmenityForm.new

      form.arrives_on = "CHRISTMAS!"

      amenity_visit_arrives_on = form.amenity_visit.arrives_on
      expect(amenity_visit_arrives_on).to be_nil
    end
  end

  describe "#parse_time (implicitly through setters)" do
    it "parses a time in %H:%M format" do
      form = Visits::AmenityForm.new

      form.arrives_at = "15:51"

      amenity_visit_arrives_at = form.amenity_visit.arrives_at
      expect(amenity_visit_arrives_at.hour).to eq 15
      expect(amenity_visit_arrives_at.min).to eq 51
    end

    it "returns nil if there is an error in parsing the time" do
      form = Visits::AmenityForm.new

      form.arrives_at = "Midnight"

      amenity_visit_arrives_at = form.amenity_visit.arrives_at
      expect(amenity_visit_arrives_at).to be_nil
    end
  end

  describe "invoiced?" do
    it "return true if invoice_id is assigned" do
      visit = create(:visit)
      invoice = create(:invoice)
      amenity_visit = create(:amenity_visit, visit: visit, invoice: invoice)
      form = Visits::AmenityForm.new(params: { amenity_visit_id: amenity_visit.id })

      expect(form.invoiced?).to be_truthy
    end

    it "return false if invoice_id not assigned" do
      visit = create(:visit)
      amenity_visit = create(:amenity_visit, visit: visit, invoice_id: nil)
      form = Visits::AmenityForm.new(params: { amenity_visit_id: amenity_visit.id })

      expect(form.invoiced?).to be_falsy
    end
  end
end
