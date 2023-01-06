require "rails_helper"

RSpec.describe "Invoice Detail" do
  let(:user) { create(:user, :confirmed) }
  let(:project) { create(:project) }
  let!(:reserve) { create(:reserve, name: "Test Reserve") }
  let!(:reserve_personnel) { create(:reserve_personnel, user: user, reserve: reserve) }
  let!(:visit) { create(:visit, reserve: reserve, starts_at: "21 sep 2022", ends_at: "31 oct 2022") }
  let(:invoice) { create(:invoice, visit: visit) }

  describe "it displays visit info" do
    it "includes invoice id, modified number, reserve name, project title, purpose of visit and visit date range", js: true do
      sign_in(user)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to be_showing_visit_info
      expect(flow).to be_showing_text(".invoice-title", "Edit Invoice #{invoice.id}-#{invoice.modify_number}")
      expect(flow).to be_showing_text(".reserve-name", reserve.name)
      expect(flow).to be_showing_text(".project-name", project.title)
      expect(flow).to be_showing_text(".visit-purpose", visit.purpose_of_visit.truncate(100, separator: ' '))
      expect(flow).to be_showing_text(".date-of-use", DateRangePresenter.new(start_date: visit.starts_at.to_date, end_date: visit.ends_at.to_date).value("date_range.different_months_same_year"))
    end
  end

  describe "it displays bill to" do
    it " includes invoice recipients table", js: true do
      sign_in(user)

      create(:project_team_membership, project: project, can_receive_invoice: true)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_edit_page
      expect(flow).to be_showing_bill_to_table
    end
  end

  describe "it display amenity visits" do
    it "includes amenity visits", js: true do
      sign_in(user)

      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10, arrives: visit.starts_at, departs: visit.ends_at)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to be_showing_amenity_visits
    end
  end

  describe "it display invoice notes" do
    it "includes notes field", js: true do
      sign_in(user)
      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to be_showing_invoice_notes
      expect(flow).to be_showing_notes_field
    end
  end

  describe "it display create button" do
    it "includes submit button", js: true do
      sign_in(user)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to have_submit_button("Edit Invoice")
    end

    it "includes back button", js: true do
      sign_in(user)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_edit_page

      expect(flow).to have_back_link("Cancel & Go Back")
    end
  end
end
