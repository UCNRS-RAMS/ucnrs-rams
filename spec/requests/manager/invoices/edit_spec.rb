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

  describe "GET /manager/reserves/:reserve_id/invoices/:id/edit" do
    it "renders the invoice visit information" do
      get edit_manager_reserve_invoice_path(reserve, invoice)

      expect(response).to be_ok

      page = Capybara.string(response.body)
      expect(page).to have_css(".invoice-title", text: "Edit Invoice #{invoice.id}-#{invoice.modify_number}")
      expect(page).to have_css(".reserve-name", text: reserve.name)
      expect(page).to have_css(".project-name", text: project.title)
      expect(page).to have_css(".visit-purpose", text: visit.purpose_of_visit)
      expect(page.find(".date-of-use").text).to be_present
    end

    it "renders the invoice recipients" do
      team_membership
      create(:invoice_recipient, invoice: invoice, user: recipient)

      get edit_manager_reserve_invoice_path(reserve, invoice)

      page = Capybara.string(response.body)
      expect(page).to have_css("#invoice-bill-to-table")
      expect(page).to have_css("#invoice-bill-to-table", text: recipient.full_name)
    end

    it "renders the amenity visits" do
      amenity_visit = create(:amenity_visit, invoice: invoice, visit: visit, rate: 10)

      get edit_manager_reserve_invoice_path(reserve, invoice)

      page = Capybara.string(response.body)
      expect(page).to have_css("section.invoice-amenity-visits")
      expect(page).to have_css("input#number_of_people#{amenity_visit.id}")
      expect(page).to have_css("section.invoice-amenity-visits", text: amenity_visit.amenity.title)
    end

    it "renders the notes field, payments table and balance" do
      create(:invoice_payment, invoice: invoice, amount: 8)

      get edit_manager_reserve_invoice_path(reserve, invoice)

      page = Capybara.string(response.body)
      expect(page).to have_css("textarea#invoice_notes")
      expect(page).to have_css("#invoice-payments-table")
      expect(page).to have_css("#balance")
    end

    it "renders the record payment, update and back controls" do
      get edit_manager_reserve_invoice_path(reserve, invoice)

      page = Capybara.string(response.body)
      expect(page).to have_css(
        "a.payment-btn[href='#{new_manager_reserve_invoice_payment_path(reserve, invoice)}']",
        text: "Record Payment"
      )
      expect(page).to have_css("button.active[form='invoices-edit']", text: "Update")
      expect(page).to have_link("Cancel & Go Back")
    end
  end
end
