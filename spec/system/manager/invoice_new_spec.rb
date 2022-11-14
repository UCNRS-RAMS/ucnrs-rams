require "rails_helper"

RSpec.describe "Invoice New" do
  let(:user) { create(:user, :confirmed) }
  let(:project) { create(:project) }
  let!(:reserve) { create(:reserve, name: "Test Reserve") }
  let!(:visit) { create(:visit, reserve: reserve, starts_at: "21 sep 2022", ends_at: "31 oct 2022") }

  describe "it displays visit info" do
    it "includes reserve name, project title, purpose of visit and visit date range", js: true do
      sign_in(user)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      flow.visit_manager_projects_invoice_new_page

      expect(flow).to be_showing_visit_info
      expect(flow).to be_showing_text(".reserve-name", reserve.name)
      expect(flow).to be_showing_text(".project-name", project.title)
      expect(flow).to be_showing_text(".visit-purpose", visit.purpose_of_visit.truncate(100, separator: ' '))
      expect(flow).to be_showing_text(".date-of-use", DateRangePresenter.value(start_date: visit.starts_at.to_date, end_date: visit.ends_at.to_date))
    end
  end

  describe "it displays bill to" do
    it " includes project team members", js: true do
      sign_in(user)

      create(:project_team_membership, project: project, can_receive_invoice: true)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      flow.visit_manager_projects_invoice_new_page

      expect(flow).to be_showing_bill_to
    end
  end

  describe "it display amenity visits" do
    it "includes amenity visits", js: true do
      sign_in(user)

      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10, arrives: visit.starts_at, departs: visit.ends_at)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      flow.visit_manager_projects_invoice_new_page

      expect(flow).to be_showing_amenity_visits
    end

    it "on change arrives date subtotal, total and days will change", js: true do
      sign_in(user)
      amenity = create(:amenity)
      amenity_rate = create(:amenity_rate, amenity: amenity)
      amenity_visit_one = create(:amenity_visit, visit: visit, number_of_people: 10, rate: 10, arrives: visit.starts_at, departs: visit.ends_at, arrives_on: visit.starts_at.to_date, departs_on: visit.ends_at.to_date, amenity: amenity, amenity_rate_id: amenity_rate.id)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      flow.visit_manager_projects_invoice_new_page
      sleep(2)

      expect(page).to have_css(".subtotal", text: "4920.00")
      expect(page).to have_css(".right-spacer", text: "41")
      expect(page).to have_css("#total", text: "4920.00")
      flow.change_arrives_date(amenity_visit_one.id, Date.parse("2022-10-21"))
      expect(page).to have_css(".subtotal", text: "1320.00")
      expect(page).to have_css(".right-spacer", text: "11")
      expect(page).to have_css("#total", text: "1320.00")
    end

    it "on change number of people subtotal and total will change", js: true do
      sign_in(user)
      amenity = create(:amenity)
      amenity_rate = create(:amenity_rate, amenity: amenity)
      amenity_visit_one = create(:amenity_visit, visit: visit, number_of_people: 10, rate: 10, arrives: visit.starts_at, departs: visit.ends_at, arrives_on: visit.starts_at.to_date, departs_on: visit.ends_at.to_date, amenity: amenity, amenity_rate_id: amenity_rate.id)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      flow.visit_manager_projects_invoice_new_page
      sleep(2)

      expect(page).to have_css(".subtotal", text: "4920.00")
      expect(page).to have_css("#total", text: "4920.00")
      flow.change_number_of_people(amenity_visit_one.id, "4")
      expect(page).to have_css(".subtotal", text: "1968.00")
      expect(page).to have_css("#total", text: "1968.00")
    end
  end

  describe "it display invoice notes" do
    it "includes notes field", js: true do
      sign_in(user)
      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      flow.visit_manager_projects_invoice_new_page

      expect(flow).to be_showing_invoice_notes
      expect(flow).to be_showing_notes_field
    end
  end

  describe "it display create button" do
    it "includes submit button", js: true do
      sign_in(user)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      flow.visit_manager_projects_invoice_new_page

      expect(flow).to have_submit_button("Create Invoice")
    end

    it "includes back button", js: true do
      sign_in(user)

      flow = Manager::InvoiceFLow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      flow.visit_manager_projects_invoice_new_page

      expect(flow).to have_back_link("Cancel & Go Back")
    end
  end
end
