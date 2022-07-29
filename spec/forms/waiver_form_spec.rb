require "rails_helper"

RSpec.describe WaiverForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:waiver) }
    it { is_expected.to delegate_method(:validate).to(:waiver) }
    it { is_expected.to delegate_method(:errors).to(:waiver) }
    it { is_expected.to delegate_missing_methods_to(:waiver) }
  end

  describe "initializing" do
    it "makes a new empty WaiverForm" do
      form = WaiverForm.new()

      expect(form).to have_attributes(
        id: nil,
        name: nil,
        description: nil,
        url: nil,
        years_to_expiration: nil,
      )
    end

    it "makes a new WaiverForm from params" do
      params = {
        id: 5,
        name: "waiver1",
        description: "description1",
        url: "url1",
        years_to_expiration: 2,
      }
      form = WaiverForm.new(params: params)

      expect(form).to have_attributes(
        id: 5,
        name: "waiver1",
        description: "description1",
        url: "url1",
        years_to_expiration: 2,
      )
    end

    it "loads an existing waiver into WaiverForm from given waiver" do
      waiver = create(:waiver, name: "special waiver")
      form = WaiverForm.new(waiver: waiver)

      expect(form).to have_attributes(name: "special waiver")
    end

    context "when waiver and param is given" do
      it "overwrites the given waiver attributes with the given params" do
        waiver = create(:waiver, name: "special waiver")
        form = WaiverForm.new(waiver: waiver, params: { name: "super special waiver" })

        expect(form).to have_attributes(id: waiver.id, name: "super special waiver")
      end
    end
  end

  describe "#save" do
    it "saves the funding if there are no errors" do
      waiver = create(:waiver, name: "special waiver")
      form = WaiverForm.new(waiver: waiver, params: { name: "super special waiver" })

      result = form.save

      expect(result).to be_truthy
      expect(form.waiver).to be_persisted
      expect(form.waiver).to have_attributes(id: waiver.id, name: "super special waiver")
    end

    it "makes sure errors are visible when save fails" do
      form = WaiverForm.new()

      result = form.save

      expect(result).to be_falsy
      expect(form.waiver).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
