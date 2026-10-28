require "rails_helper"

RSpec.describe "Invoice New", type: :system, js: true do
  let(:user) { create(:user, :confirmed) }
  let(:project) { create(:project) }
  let!(:reserve) { create(:reserve, name: "Test Reserve") }
  let!(:reserve_personnel) { create(:reserve_personnel, user: user, reserve: reserve) }
  let!(:visit) { create(:visit, reserve: reserve, starts_at: "21 sep 2022", ends_at: "31 oct 2022") }

  describe "it display amenity visits" do
    it "on change number of people subtotal and total will change" do
      amenity = create(:amenity)
      amenity_rate = create(:amenity_rate, amenity: amenity, rate: 12.50)
      amenity_visit_one = create(:amenity_visit, visit: visit, number_of_people: 10,
        arrives: visit.starts_at, departs: visit.ends_at,
        arrives_on: visit.starts_at.to_date, departs_on: visit.ends_at.to_date,
        amenity: amenity, amenity_rate_id: amenity_rate.id, invoice_id: nil,
        rate: 12.50)

      flow = Manager::InvoiceFlow.new(page: page, visit_id: visit.id, reserve_id: reserve.id)
      sign_in(user)

      flow.visit_manager_projects_invoice_new_page
      expect(page).to have_css(".subtotal", text: "5125.00")
      expect(page).to have_css("#total", text: "5125.00")

      flow.change_number_of_people(amenity_visit_one.id, "4")
      expect(page).to have_css(".subtotal", text: "2050.00")
      expect(page).to have_css("#total", text: "2050.00")
    end
  end
end
