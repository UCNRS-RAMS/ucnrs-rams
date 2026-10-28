require "rails_helper"

RSpec.describe Manager::InvoicesController, type: :request do
  let(:reserve) { create(:reserve, name: "Test Reserve") }
  let(:project) { create(:project) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:recipient) { create(:user, :confirmed) }
  let(:team_membership) do
    create(:project_team_membership, project: project, user: recipient, can_receive_invoice: true)
  end
  let(:invoice) { create(:invoice, visit: visit) }
  let(:user) { create(:user, :confirmed) }

  before do
    create(:reserve_personnel, user: user, reserve: reserve)
    sign_in(user)
  end

  describe "GET /manager/reserves/:reserve_id/invoices/:id" do
    it "renders the invoice visit information" do
      get manager_reserve_invoice_path(reserve, invoice)

      expect(response).to be_ok

      page = Capybara.string(response.body)
      expect(page).to have_css(".invoice-title", text: "Invoice #{invoice.id}-#{invoice.modify_number}")
      expect(page).to have_css(".reserve-name", text: reserve.name)
      expect(page).to have_css(".project-name", text: project.title)
      expect(page).to have_css(".visit-purpose", text: visit.purpose_of_visit)
      expect(page.find(".date-of-use").text).to be_present
    end

    it "renders the invoice recipients" do
      team_membership
      create(:invoice_recipient, invoice: invoice, user: recipient)

      get manager_reserve_invoice_path(reserve, invoice)

      page = Capybara.string(response.body)
      expect(page).to have_css("#invoice-bill-to-table")
      expect(page).to have_css("tr.team-membership", count: 1)
      expect(page).to have_css("tr.team-membership", text: recipient.full_name)
    end

    it "renders the invoiced amenity visits and their total" do
      amenity_visit = create(:amenity_visit, invoice: invoice, visit: visit, rate: 10, number_of_people: 2)

      get manager_reserve_invoice_path(reserve, invoice)

      page = Capybara.string(response.body)
      expect(page).to have_css("#amenities-summary-table")
      expect(page).to have_css("tr.amenity_visit", count: 1)
      expect(page).to have_css("tr.amenity_visit", text: amenity_visit.amenity.title)
      expect(page).to have_css("#amenities-summary-table td.amenity-visit-subtotal", text: "$")
      expect(page).to have_css("td.balance")
    end

    it "renders the saved notes without a notes field" do
      invoice.update!(notes: "Thanks for the stay")

      get manager_reserve_invoice_path(reserve, invoice)

      page = Capybara.string(response.body)
      expect(page).to have_css("pre.saved-note", text: "Thanks for the stay")
      expect(page).to have_no_css("textarea#invoice_notes")
    end

    it "renders the invoice action links" do
      get manager_reserve_invoice_path(reserve, invoice)

      page = Capybara.string(response.body)
      expect(page).to have_css(".action-buttons")
      expect(page).to have_css(".action-buttons a[href='#{edit_manager_reserve_invoice_path(reserve, invoice)}'] img.edit")
      expect(page).to have_css(".action-buttons img.delete")
    end
  end
end
