# frozen_string_literal: true

require "rails_helper"

RSpec.describe AmenityForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:amenity) }
    it { is_expected.to delegate_method(:validate).to(:amenity) }
    it { is_expected.to delegate_method(:errors).to(:amenity) }
    it { is_expected.to delegate_missing_methods_to(:amenity) }
  end

  describe "initializing" do
    it "makes a new empty AmenityForm" do
      form = AmenityForm.new

      expect(form).to have_attributes(
        id: nil,
        reserve_id: nil,
        title: "",
        comment: "",
        total_capacity: 0,
        units_type: nil,
        time_type: "day",
        sort_order: 255,
        visible: true,
        disable: false,
        default_select: false,
        show_on_invoice: true,
        outside_reservation_system: false,
        email_notification_system: false,
        email_notification_address: nil,
        amenities_code: "-",
        group_number: nil,
        amenities_type: nil,
        listing_photo_url: nil,
      )
    end

    it "makes a new AmenityForm from params" do
      image = File.open(Rails.root.join('spec', 'support', 'assets', 'test-image.jpeg'))
      params = {
        id: 4,
        reserve_id: 4,
        title: "title",
        comment: "comment",
        total_capacity: 1,
        units_type: "person",
        time_type: "night",
        sort_order: 1,
        visible: false,
        disable: true,
        default_select: true,
        show_on_invoice: false,
        outside_reservation_system: true,
        email_notification_system: true,
        email_notification_address: nil,
        amenities_code: "-",
        group_number: nil,
        amenities_type: nil,
        listing_photo: image,
      }
      form = AmenityForm.new(params: params)

      expect(form).to have_attributes(
        id: 4,
        reserve_id: 4,
        title: "title",
        comment: "comment",
        total_capacity: 1,
        units_type: "person",
        time_type: "night",
        sort_order: 1,
        visible: false,
        disable: true,
        default_select: true,
        show_on_invoice: false,
        outside_reservation_system: true,
        email_notification_system: true,
        email_notification_address: nil,
        amenities_code: "-",
        group_number: nil,
        amenities_type: nil,
        listing_photo_url:
          a_string_matching(/\/tmp\/ucnrs-test\/cache\/\S+\/test-image.jpeg/),
      )
    end

    it "loads an existing amenity into AmenityForm from given amenity" do
      amenity = create(:amenity, title: "title 1")
      form = AmenityForm.new(amenity: amenity)

      expect(form).to have_attributes(id: amenity.id, title: "title 1")
    end

    context "when an amenity and params is given" do
      it "overwrites the given amenity attributes with the given params" do
        amenity = create(:amenity, title: "title old")
        form = AmenityForm.new(amenity: amenity, params: { title: "title new" })

        expect(form).to have_attributes(id: amenity.id, title: "title new")
      end
    end
  end

  describe "#save" do
    it "saves the amenity if there are no errors" do
      amenity = create(:amenity, title: "title old")
      form = AmenityForm.new(amenity: amenity, params: { title: "title new" })

      result = form.save

      expect(result).to be_truthy
      expect(form.amenity).to be_persisted
      expect(form.amenity).to have_attributes(id: amenity.id, title: "title new")
    end

    it "makes sure errors are visible when save fails" do
      form = AmenityForm.new()

      result = form.save

      expect(result).to be_falsy
      expect(form.amenity).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
