# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReservePersonnelForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:valid?).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:validate).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:errors).to(:reserve_personnel) }
    it { is_expected.to delegate_missing_methods_to(:reserve_personnel) }
  end

  describe "initializing" do
    it "makes a new empty ReservePersonnelForm" do
      form = ReservePersonnelForm.new

      expect(form).to have_attributes(
        id: nil,
        reserve_id: nil,
        user_id: nil,
        receive_invoice_email: false,
        receive_update_email: false,
        receive_iacuc_email: false,
        receive_incomplete_visit_email: false,
        receive_approval_email: false,
        receive_drone_email: false,
        receive_scuba_email: false,
        receive_new_visit_email: false,
        phone_number: nil,
        email: nil
      )
    end

    it "makes a new ReservePersonnelForm from params" do
      params = {
        id: 6,
        reserve_id: 6,
        user_id: 6,
        receive_invoice_email: true,
        receive_update_email: true,
        receive_iacuc_email: true,
        receive_incomplete_visit_email: true,
        receive_approval_email: true,
        receive_drone_email: true,
        receive_scuba_email: true,
        receive_new_visit_email: true,
        phone_number: "111-222-3333",
        email: "someone@address.com",
      }
      form = ReservePersonnelForm.new(params: params)

      expect(form).to have_attributes(
        id: 6,
        reserve_id: 6,
        user_id: 6,
        receive_invoice_email: true,
        receive_update_email: true,
        receive_iacuc_email: true,
        receive_incomplete_visit_email: true,
        receive_approval_email: true,
        receive_drone_email: true,
        receive_scuba_email: true,
        receive_new_visit_email: true,
        phone_number: "111-222-3333",
        email: "someone@address.com",
      )
    end

    it "loads an existing reserve_personnel into ReservePersonnelForm from given reserve_personnel" do
      reserve_personnel = create(:reserve_personnel, email: "someone@address.com")
      form = ReservePersonnelForm.new(reserve_personnel: reserve_personnel)

      expect(form).to have_attributes(id: reserve_personnel.id, email: "someone@address.com")
    end

    context "when an reserve_personnel and params is given" do
      it "overwrites the given reserve_personnel attributes with the given params" do
        reserve_personnel = create(:reserve_personnel, email: "email_old@address.com")
        form = ReservePersonnelForm.new(reserve_personnel: reserve_personnel, params: { email: "email_new@address.com" })

        expect(form).to have_attributes(id: reserve_personnel.id, email: "email_new@address.com")
      end
    end
  end

  describe "#save" do
    it "saves the reserve_personnel if there are no errors" do
      reserve_personnel = create(:reserve_personnel, email: "email_old@address.com")
      form = ReservePersonnelForm.new(reserve_personnel: reserve_personnel, params: { email: "email_new@address.com" })

      result = form.save

      expect(result).to be_truthy
      expect(form.reserve_personnel).to be_persisted
      expect(form.reserve_personnel).to have_attributes(id: reserve_personnel.id, email: "email_new@address.com")
    end

    it "makes sure errors are visible when save fails" do
      form = ReservePersonnelForm.new()

      result = form.save

      expect(result).to be_falsy
      expect(form.reserve_personnel).to_not be_persisted
      expect(form.errors).to be_present
    end
  end
end
