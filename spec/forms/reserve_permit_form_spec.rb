# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReservePermitForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:reserve_permit) }
    it { is_expected.to delegate_method(:validate).to(:reserve_permit) }
    it { is_expected.to delegate_method(:errors).to(:reserve_permit) }
    it { is_expected.to delegate_missing_methods_to(:reserve_permit) }
  end

  describe "initializing" do
    it "makes a new empty ReservePermitForm" do
      form = ReservePermitForm.new

      expect(form).to have_attributes(
        id: nil,
        reserve_id: nil,
        permit_id: nil,
        reserve_specific_text: nil,
        sort_order_override: nil,
        visible: true,
        collect_permit_information: false,
        research_project: true,
        class_project: true,
        public_project: false,
        housing_only_project: false,
        conference_project: false,
      )
    end

    it "makes a new ReservePermitForm from params" do
      params = {
        id: 8,
        reserve_id: 8,
        permit_id: 8,
        reserve_specific_text: "Do it",
        sort_order_override: 1,
        visible: false,
        collect_permit_information: true,
        research_project: false,
        class_project: false,
        public_project: true,
        housing_only_project: true,
        conference_project: true,
      }
      form = ReservePermitForm.new(params: params)

      expect(form).to have_attributes(
        id: 8,
        reserve_id: 8,
        permit_id: 8,
        reserve_specific_text: "Do it",
        sort_order_override: 1,
        visible: false,
        collect_permit_information: true,
        research_project: false,
        class_project: false,
        public_project: true,
        housing_only_project: true,
        conference_project: true,
      )
    end

    it "loads an existing reserve_permit into ReservePermitForm from given reserve_permit" do
      reserve_permit = create(:reserve_permit, reserve_specific_text: "title 1")
      form = ReservePermitForm.new(reserve_permit: reserve_permit)

      expect(form).to have_attributes(id: reserve_permit.id, reserve_specific_text: "title 1")
    end

    context "when an reserve_permit and params is given" do
      it "overwrites the given reserve_permit attributes with the given params" do
        reserve_permit = create(:reserve_permit, reserve_specific_text: "title old")
        form = ReservePermitForm.new(reserve_permit: reserve_permit, params: { reserve_specific_text: "title new" })

        expect(form).to have_attributes(id: reserve_permit.id, reserve_specific_text: "title new")
      end
    end
  end

  describe "#save" do
    it "saves the reserve_permit if there are no errors" do
      reserve_permit = create(:reserve_permit, reserve_specific_text: "title old")
      form = ReservePermitForm.new(reserve_permit: reserve_permit, params: { reserve_specific_text: "title new" })

      result = form.save

      expect(result).to be_truthy
      expect(form.reserve_permit).to be_persisted
      expect(form.reserve_permit).to have_attributes(id: reserve_permit.id, reserve_specific_text: "title new")
    end

    it "makes sure errors are visible when save fails" do
      form = ReservePermitForm.new()

      result = form.save

      expect(result).to be_falsy
      expect(form.reserve_permit).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
