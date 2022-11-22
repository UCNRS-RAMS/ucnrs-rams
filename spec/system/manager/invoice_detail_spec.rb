require "rails_helper"

RSpec.describe "Invoice Detail" do
  let(:user) { create(:user, :confirmed) }
  let(:project) { create(:project) }
  let!(:reserve) { create(:reserve, name: "Test Reserve") }
  let!(:reserve_personnel) { create(:reserve_personnel, user: user, reserve: reserve) }
  let!(:visit) { create(:visit, reserve: reserve, starts_at: "21 sep 2022", ends_at: "31 oct 2022") }
  let!(:invoice) { create(:invoice, visit: visit) }

  describe "it displays visit info" do
    it "includes invoice id, modified number, reserve name, project title, purpose of visit and visit date range", js: true do
      sign_in(user)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_detail_page

      expect(flow).to be_showing_visit_info
      expect(flow).to be_showing_text(".invoice-title", "Invoice #{invoice.id}-#{invoice.modify_number}")
      expect(flow).to be_showing_text(".reserve-name", reserve.name)
      expect(flow).to be_showing_text(".project-name", project.title)
      expect(flow).to be_showing_text(".visit-purpose", visit.purpose_of_visit.truncate(100, separator: ' '))
      expect(flow).to be_showing_text(".date-of-use", DateRangePresenter.new(start_date: visit.starts_at.to_date, end_date: visit.ends_at.to_date).value("date_range.different_years"))
    end
  end

  describe "it displays bill to" do
    it " includes invoice recipients table", js: true do
      sign_in(user)

      create(:project_team_membership, project: project, can_receive_invoice: true)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_detail_page

      expect(flow).to be_showing_bill_to_table
    end
  end

  describe "it display amenity visits table" do
    it "includes amenity visits", js: true do
      sign_in(user)

      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10, arrives: visit.starts_at, departs: visit.ends_at)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_detail_page

      expect(flow).to be_showing_amenity_visit_table
    end
  end

  describe "it display invoice notes" do
    it "includes note message", js: true do
      sign_in(user)
      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
      flow.visit_manager_projects_invoice_detail_page

      expect(flow).to be_showing_saved_note
      expect(flow).not_to be_showing_notes_field
    end
  end

  describe "Invoice detail page action buttons" do
    context "when click on trash icon" do
      it "invoice will delete after confirmation ", js: true do
        sign_in(user)
        flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
        flow.visit_manager_projects_invoice_detail_page
        flow.click_trash_icon
        sleep(0.1)

        expect(flow).to be_deleted_invoice
      end
    end

    context "when click on Record payment button" do
      it "payment modal will open", js: true do
        sign_in(user)
        flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
        flow.visit_manager_projects_invoice_detail_page
        flow.click_payment_btn

        expect(flow).to be_showing_payment_madal
      end

      it "display errors if submit invalid data", js: true do
        sign_in(user)
        flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
        flow.visit_manager_projects_invoice_detail_page
        flow.click_payment_btn
        flow.click_save_btn

        expect(flow).to be_showing_errors
      end

      it "will not display error if data is valid", js: true do
        sign_in(user)

        flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id, invoice_id: invoice.id)
        flow.visit_manager_projects_invoice_detail_page
        flow.click_payment_btn
        flow.fill_payment_form
        flow.click_save_btn

        expect(flow).not_to be_showing_errors
      end
    end
  end
end
