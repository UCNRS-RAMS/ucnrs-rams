require "rails_helper"

RSpec.describe "Invoice Edit Page", type: :system, js: true do
  let(:user) { create(:user, :confirmed) }
  let(:project) { create(:project) }
  let!(:reserve) { create(:reserve, name: "Test Reserve") }
  let!(:reserve_personnel) { create(:reserve_personnel, user: user, reserve: reserve) }
  let!(:visit) do
    create(:visit,
      reserve: reserve,
      project: project,
      starts_at: "21 sep 2022",
      ends_at: "31 oct 2022",
    )
  end
  let(:invoice) { create(:invoice, visit: visit) }

  describe "visit info section" do
    it "shows the invoice id, reserve name, project title, purpose, and date range" do
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to be_showing_visit_info
      expect(flow).to be_showing_text(".invoice-title", "Edit Invoice #{invoice.id}-#{invoice.modify_number}")
      expect(flow).to be_showing_text(".reserve-name", reserve.name)
      expect(flow).to be_showing_text(".project-name", project.title)
      expect(flow).to be_showing_text(".visit-purpose", visit.purpose_of_visit.truncate(100, separator: ' '))
      expect(flow).to be_showing_text(".date-of-use",
        DateRangePresenter.new(start_date: visit.starts_at.to_date, end_date: visit.ends_at.to_date)
          .value("date_range.different_months_same_year")
      )
    end
  end

  describe "bill-to section" do
    it "includes the invoice recipients table" do
      create(:project_team_membership, project: project, can_receive_invoice: true)

      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to be_showing_bill_to_table
    end
  end

  describe "amenity visits section" do
    it "lists the amenity visits" do
      create(:amenity_visit,
        visit: visit,
        number_of_people: 10,
        manual_units_of_time: 10,
        rate: 10,
        arrives: visit.starts_at,
        departs: visit.ends_at,
      )

      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to be_showing_amenity_visits
    end
  end

  describe "invoice notes section" do
    it "renders the notes field" do
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to be_showing_invoice_notes
      expect(flow).to be_showing_notes_field
    end
  end

  describe "action buttons" do
    it "renders an Update submit button" do
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to have_submit_button("Update")
    end

    it "renders a Cancel & Go Back link" do
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to have_back_link("Cancel & Go Back")
    end
  end

  describe "submitting the update form" do
    let!(:project_team_membership) do
      create(:project_team_membership, project: visit.project, can_receive_invoice: true)
    end
    let!(:amenity_visit) do
      create(:amenity_visit,
        visit: visit,
        invoice: invoice,
        number_of_people: 10,
        rate: 10,
        arrives: visit.starts_at,
        departs: visit.ends_at,
      )
    end

    it "persists the notes and redirects to the show page" do
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page
      flow.fill_notes("Updated invoice notes")
      flow.click_update_btn

      expect(flow).to be_on_invoice_show_page
      expect(invoice.reload.notes).to eq("Updated invoice notes")
    end

    it "increments the modify_number" do
      old_modify_number = invoice.modify_number.to_i
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page
      flow.fill_notes("Bump revision")
      flow.click_update_btn

      expect(flow).to be_on_invoice_show_page
      expect(invoice.reload.modify_number.to_i).to eq(old_modify_number + 1)
    end
  end

  describe "when clicking the Record Payment button" do
    it "opens the payment modal" do
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page
      flow.click_payment_btn

      expect(flow).to be_showing_payment_modal
    end

    it "shows errors when submitting invalid data" do
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page
      flow.click_payment_btn
      flow.click_save_btn

      expect(flow).to be_showing_errors
    end

    it "does not show errors when submitting valid data" do
      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_edit_page
      flow.click_payment_btn
      flow.fill_payment_form
      flow.click_save_btn

      expect(flow).not_to be_showing_errors
    end
  end
end
