require "rails_helper"

RSpec.describe InvoiceForm, type: :model do
  let(:visit) { create(:visit) }
  describe "delegations" do
    subject { InvoiceForm.new(params: {visit_id: visit.id}) }
    it { is_expected.to delegate_method(:id).to(:invoice).with_prefix(true).allow_nil }
  end

  describe "initializing" do
    it "makes amenity_visit, visit object and an empty invoice object" do
      visit = create(:visit)
      amenity_visit = create(:amenity_visit, visit: visit)
      form = InvoiceForm.new(params: { visit_id: visit.id })

      expect(form.invoice).to have_attributes(
        id: nil,
        visit_id: nil,
        invoiced_on: nil,
        notes: nil,
        modify_number: 0,
        rams1_billed_amount: nil,
        balance_due: nil,
        created_at: nil,
        updated_at: nil,
      )

      expect(form.visit).to have_attributes(
        id: visit.id,
        project_id: visit.project_id,
        reserve_id: visit.reserve_id,
      )

      expect(form.amenity_visits.first).to have_attributes(
        id: amenity_visit.id,
        visit_id: visit.id,
        amenity_id: amenity_visit.amenity_id,
      )
    end
  end

  describe "#save" do
    it "saves both the amenity_visits, invoice and invoice_recipients if there are no errors" do
      visit = create(:visit)
      amenity_visit = create(:amenity_visit, visit: visit)
      user = create(:user)

      project_team_members = create(:project_team_membership)
      form = InvoiceForm.new(invoice: Invoice.new({ notes: "hello", visit_id: visit.id }), params: {
        project_team_members: {
          project_team_members.id.to_s => {
            user_id: user.id.to_s,
            check: "1",
          },
        },
        amenity_visit => {
          amenity_visit.id.to_s => {
            checked: "1",
            amenity_visit_id: amenity_visit.id,
            status: "approved",
            arrives: amenity_visit.arrives,
            departs: amenity_visit.departs,
            number_of_people: amenity_visit.number_of_people,
            amenity_rate_id: amenity_visit.amenity_rate_id,
          },
        },
        invoice: {
          notes: "hello",
          visit_id: visit.id,
        },
        visit_id: visit.id.to_s,
      })
      result = form.save
      expect(result).to be_truthy
    end

    it "makes sure all errors are visible when save fails" do
      visit = create(:visit)
      amenity_visit = create(:amenity_visit, visit: visit)
      user = create(:user)

      project_team_members = create(:project_team_membership)
      form = InvoiceForm.new(invoice: Invoice.new({ notes: "hello", visit_id: visit.id }), params: {
        project_team_members: {
          project_team_members.id.to_s => {
            user_id: user.id.to_s,
            check: "1",
          },
        },
        amenity_visit => {
          amenity_visit.id.to_s => {
            checked: "1",
            amenity_visit_id: amenity_visit.id,
            status: "approved",
            arrives: amenity_visit.arrives,
            departs: amenity_visit.arrives,
            number_of_people: amenity_visit.number_of_people,
            amenity_rate_id: amenity_visit.amenity_rate_id,
          },
        },
        invoice: {
          notes: "hello",
          visit_id: visit.id,
        },
        visit_id: visit.id.to_s,
      })

      form.amenity_visits.first.departs = form.amenity_visits.first.arrives - 1.day
      result = form.save
      expect(result).to be_falsy
      expect(form.amenity_visits.first.errors).to be_present
    end
  end
end
