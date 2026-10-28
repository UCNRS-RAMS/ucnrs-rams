require "rails_helper"

RSpec.describe Manager::InvoicesController, type: :request do
  let(:reserve) { create(:reserve) }
  let(:project) { create(:project) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:recipient) { create(:user, :confirmed) }
  let(:team_membership) do
    create(:project_team_membership, project: project, user: recipient, can_receive_invoice: true)
  end
  let(:invoice) { create(:invoice, visit: visit) }
  let(:amenity_visit) do
    create(
      :amenity_visit,
      invoice: invoice,
      visit: visit,
      number_of_people: 10,
      rate: 10,
      arrives_on: Date.new(2022, 9, 21),
      departs_on: Date.new(2022, 10, 31)
    )
  end
  let(:user) { create(:user, :confirmed) }

  before do
    create(:reserve_personnel, user: user, reserve: reserve)
    sign_in(user)
  end

  describe "PATCH /manager/reserves/:reserve_id/invoices/:id" do
    it "updates the invoice notes, amenity visit values and recipients" do
      team_membership
      amenity_visit
      original_modify_number = invoice.modify_number

      patch manager_reserve_invoice_path(reserve, invoice), params: {
        invoice: {
          notes: "Updated invoice notes",
          invoiced_on: invoice.invoiced_on.to_s,
          modify_number: (original_modify_number + 1).to_s
        },
        project_team_members: {
          team_membership.id.to_s => { user_id: recipient.id.to_s, check: "1" }
        },
        amenity_visit: {
          amenity_visit.id.to_s => {
            amenity_visit_id: amenity_visit.id.to_s,
            checked: "1",
            arrives_on: "2022-09-21",
            departs_on: "2022-10-31",
            number_of_people: "4",
            rate: "10",
            status: "approved"
          }
        }
      }

      expect(response).to redirect_to(manager_reserve_invoice_path(reserve, invoice))

      invoice.reload
      expect(invoice.notes).to eq("Updated invoice notes")
      expect(invoice.modify_number).to eq(original_modify_number + 1)
      expect(amenity_visit.reload.number_of_people).to eq(4)
      expect(invoice.invoice_recipients.pluck(:user_id)).to eq([ recipient.id ])
    end

    it "re-renders the edit form when an amenity visit is invalid" do
      team_membership
      amenity_visit
      original_modify_number = invoice.modify_number

      patch manager_reserve_invoice_path(reserve, invoice), params: {
        invoice: {
          notes: "Should not persist",
          invoiced_on: invoice.invoiced_on.to_s,
          modify_number: (original_modify_number + 1).to_s
        },
        project_team_members: {
          team_membership.id.to_s => { user_id: recipient.id.to_s, check: "1" }
        },
        amenity_visit: {
          amenity_visit.id.to_s => {
            amenity_visit_id: amenity_visit.id.to_s,
            checked: "1",
            arrives_on: "2022-09-21",
            departs_on: "2022-10-31",
            number_of_people: "0",
            rate: "10",
            status: "approved"
          }
        }
      }

      expect(response).to be_ok

      invoice.reload
      expect(invoice.notes).to eq("Note for invoice")
      expect(invoice.modify_number).to eq(original_modify_number)
      expect(invoice.invoice_recipients).to be_empty
      expect(amenity_visit.reload.number_of_people).to eq(10)

      page = Capybara.string(response.body)
      expect(page).to have_css("#invoices-edit")
      expect(page).to have_css(".invoice-title", text: "Edit Invoice #{invoice.id}-")
    end
  end
end
