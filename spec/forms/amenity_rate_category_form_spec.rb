# frozen_string_literal: true

require "rails_helper"

RSpec.describe AmenityRateCategoryForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:amenity_rate_category) }
    it { is_expected.to delegate_method(:validate).to(:amenity_rate_category) }
    it { is_expected.to delegate_method(:errors).to(:amenity_rate_category) }
    it { is_expected.to delegate_missing_methods_to(:amenity_rate_category) }
  end

  describe "initializing" do
    it "makes a new empty AmenityRateCategoryForm" do
      form = AmenityRateCategoryForm.new

      expect(form).to have_attributes(
        id: nil,
        reserve_id: nil,
        description: nil,
        sort_order: 0,
        visible: true,
        state_university: false,
        state_college: false,
        community_college: false,
        other_state_institution: false,
        outside_state: false,
        international: false,
        K12: false,
        nongovernmental: false,
        governmental: false,
        business: false,
        other: false,
      )
    end

    it "makes a new AmenityRateCategoryForm from params" do
      params = {
        id: 4,
        reserve_id: 4,
        description: "title",
        sort_order: 1,
        visible: false,
        state_university: true,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: true,
        governmental: true,
        business: true,
        other: true,
      }
      form = AmenityRateCategoryForm.new(params: params)

      expect(form).to have_attributes(
        id: 4,
        reserve_id: 4,
        description: "title",
        sort_order: 1,
        visible: false,
        state_university: true,
        state_college: true,
        community_college: true,
        other_state_institution: true,
        outside_state: true,
        international: true,
        K12: true,
        nongovernmental: true,
        governmental: true,
        business: true,
        other: true,
      )
    end

    it "loads an existing amenity_rate_category into AmenityRateCategoryForm from given amenity_rate_category" do
      amenity_rate_category = create(:amenity_rate_category, description: "title 1")
      form = AmenityRateCategoryForm.new(amenity_rate_category: amenity_rate_category)

      expect(form).to have_attributes(id: amenity_rate_category.id, description: "title 1")
    end

    context "when an amenity_rate_category and params is given" do
      it "overwrites the given amenity_rate_category attributes with the given params" do
        amenity_rate_category = create(:amenity_rate_category, description: "title old")
        form = AmenityRateCategoryForm.new(amenity_rate_category: amenity_rate_category, params: { description: "title new" })

        expect(form).to have_attributes(id: amenity_rate_category.id, description: "title new")
      end
    end
  end

  describe "#save" do
    it "saves the amenity_rate_category if there are no errors" do
      amenity_rate_category = create(:amenity_rate_category, description: "title old")
      form = AmenityRateCategoryForm.new(amenity_rate_category: amenity_rate_category, params: { description: "title new" })

      result = form.save

      expect(result).to be_truthy
      expect(form.amenity_rate_category).to be_persisted
      expect(form.amenity_rate_category).to have_attributes(id: amenity_rate_category.id, description: "title new")
    end

    it "makes sure errors are visible when save fails" do
      form = AmenityRateCategoryForm.new()

      result = form.save

      expect(result).to be_falsy
      expect(form.amenity_rate_category).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
