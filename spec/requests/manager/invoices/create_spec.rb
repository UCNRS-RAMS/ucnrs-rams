require "rails_helper"

RSpec.describe Manager::InvoicesController, type: :request do
  let(:reserve) { create(:reserve) }
  let(:project) { create(:project) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:user) { create(:user, :confirmed) }
  let(:recipient) { create(:user, :confirmed) }
  let(:team_membership) do
    create(:project_team_membership, project: project, user: recipient, can_receive_invoice: true)
  end
  let(:amenity_visit) do
    create(
      :amenity_visit,
      visit: visit,
      invoice: nil,
      number_of_people: 10,
      rate: 10,
      arrives_on: Date.new(2022, 9, 21),
      departs_on: Date.new(2022, 10, 31)
    )
  end

  before do
    create(:reserve_personnel, user: user, reserve: reserve)
    sign_in(user)
  end

  describe "POST /manager/reserves/:reserve_id/visits/:visit_id/invoices" do
    it "creates the invoice with its amenity visits and recipients" do
      team_membership
      amenity_visit

      expect do
        post manager_reserve_visit_invoices_path(reserve, visit), params: {
          invoice: { notes: "Invoice notes", invoiced_on: "", modify_number: "0" },
          project_team_members: {
            team_membership.id.to_s => { user_id: recipient.id.to_s, check: "1" }
          },
          amenity_visit: {
            amenity_visit.id.to_s => {
              amenity_visit_id: amenity_visit.id.to_s,
              checked: "1",
              arrives_on: "2022-09-21",
              departs_on: "2022-10-31",
              number_of_people: "10",
              rate: "10",
              status: "approved"
            }
          }
        }
      end.to change(Invoice, :count).by(1)

      invoice = Invoice.last
      expect(response).to redirect_to(manager_reserve_invoice_path(reserve, invoice))
      expect(invoice.notes).to eq("Invoice notes")
      expect(invoice.invoiced_on).to eq(Time.zone.today)
      expect(invoice.amenity_visits).to contain_exactly(amenity_visit)
      expect(invoice.invoice_recipients.pluck(:user_id)).to eq([ recipient.id ])
    end

    it "re-renders the form with an alert when the visit has no amenity visits" do
      expect do
        post manager_reserve_visit_invoices_path(reserve, visit), params: {
          invoice: { notes: "Invoice notes", invoiced_on: "", modify_number: "0" }
        }
      end.not_to change(Invoice, :count)

      expect(response).to be_ok
      expect(flash.now[:alert]).to eq(I18n.translate("manager.no_amenity_visit"))

      page = Capybara.string(response.body)
      expect(page).to have_css("section.invoice-visit-info")
      expect(page).to have_css(".alert", text: I18n.translate("manager.no_amenity_visit"))
      expect(page).to have_css("button.active[form='invoices-new']", text: "Create Invoice")
    end

    it "does not persist the invoice when an amenity visit is invalid" do
      team_membership
      amenity_visit

      expect do
        post manager_reserve_visit_invoices_path(reserve, visit), params: {
          invoice: { notes: "Invoice notes", invoiced_on: "", modify_number: "0" },
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
      end.not_to change(Invoice, :count)

      expect(response).to be_ok
      expect(amenity_visit.reload.number_of_people).to eq(10)

      page = Capybara.string(response.body)
      expect(page).to have_css("#invoices-new")
    end
  end
end
