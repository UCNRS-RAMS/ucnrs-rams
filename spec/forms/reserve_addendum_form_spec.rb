# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReserveAddendumForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:validate).to(:reserve_addendum) }
    it { is_expected.to delegate_method(:errors).to(:reserve_addendum) }
    it { is_expected.to delegate_missing_methods_to(:reserve_addendum) }
  end

  describe "initializing" do
    it "makes a new empty ReserveAddendumForm" do
      form = ReserveAddendumForm.new

      expect(form).to have_attributes(
        id: nil,
        reserve_id: nil,
        sort_order: 1,
        name: nil
      )
    end

    it "makes a new ReserveAddendumForm from params" do
      params = {
        id: 4,
        reserve_id: 7,
        sort_order: 5,
        name: "addendum name",
      }
      form = ReserveAddendumForm.new(params: params)

      expect(form).to have_attributes(
        id: 4,
        reserve_id: 7,
        sort_order: 5,
        name: "addendum name",
      )
    end

    it "loads an existing reserve_addendum into ReserveAddendumForm from given reserve_addendum" do
      reserve_addendum = create(:reserve_addendum, name: "name 1")
      form = ReserveAddendumForm.new(reserve_addendum: reserve_addendum)

      expect(form).to have_attributes(id: reserve_addendum.id, name: "name 1")
    end

    context "when an reserve_addendum and params is given" do
      it "overwrites the given reserve_addendum attributes with the given params" do
        reserve_addendum = create(:reserve_addendum, name: "name old")
        form = ReserveAddendumForm.new(reserve_addendum: reserve_addendum, params: { name: "name new" })

        expect(form).to have_attributes(id: reserve_addendum.id, name: "name new")
      end
    end
  end

  describe "#save" do
    it "saves the reserve_addendum if there are no errors" do
      reserve_addendum = create(:reserve_addendum, name: "name old")
      form = ReserveAddendumForm.new(reserve_addendum: reserve_addendum, params: { name: "name new" })

      result = form.save

      expect(result).to be_truthy
      expect(form.reserve_addendum).to be_persisted
      expect(form.reserve_addendum).to have_attributes(id: reserve_addendum.id, name: "name new")
    end

    it "makes sure errors are visible when save fails" do
      form = ReserveAddendumForm.new()

      result = form.save

      expect(result).to be_falsy
      expect(form.reserve_addendum).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
