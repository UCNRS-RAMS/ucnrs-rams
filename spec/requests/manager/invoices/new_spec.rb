require "rails_helper"

RSpec.describe Manager::InvoicesController, type: :request do
  let(:reserve) { create(:reserve, name: "Test Reserve") }
  let(:project) { create(:project) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:user) { create(:user, :confirmed) }

  before do
    create(:reserve_personnel, user: user, reserve: reserve)
    sign_in(user)
  end

  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/invoices/new" do
    it "renders the visit information" do
      get new_manager_reserve_visit_invoice_path(reserve, visit)

      expect(response).to be_ok

      page = Capybara.string(response.body)
      expect(page).to have_css("section.invoice-visit-info")
      expect(page).to have_css(".reserve-name", text: reserve.name)
      expect(page).to have_css(".project-name", text: project.title)
      expect(page).to have_css(".visit-purpose", text: visit.purpose_of_visit)
      expect(page.find(".date-of-use").text).to be_present
    end

    it "renders the bill to recipients" do
      team_membership = create(:project_team_membership, project: project, can_receive_invoice: true)

      get new_manager_reserve_visit_invoice_path(reserve, visit)

      page = Capybara.string(response.body)
      expect(page).to have_css("section.invoice-bill-to")
      expect(page).to have_css("#invoice-bill-to-table", text: team_membership.user.full_name)
      expect(page).to have_css("#invoice-bill-to-table", text: team_membership.user.email)
    end

    it "renders the amenity visits" do
      amenity_visit = create(
        :amenity_visit,
        visit: visit,
        invoice: nil,
        number_of_people: 10,
        manual_units_of_time: 10,
        rate: 10
      )

      get new_manager_reserve_visit_invoice_path(reserve, visit)

      page = Capybara.string(response.body)
      expect(page).to have_css("section.invoice-amenity-visits")
      expect(page).to have_css("input#number_of_people#{amenity_visit.id}")
      expect(page).to have_css("section.invoice-amenity-visits", text: amenity_visit.amenity.title)
    end

    it "renders the notes field and the create button without a back link" do
      get new_manager_reserve_visit_invoice_path(reserve, visit)

      page = Capybara.string(response.body)
      expect(page).to have_css("textarea#invoice_notes")
      expect(page).to have_css("button.active[form='invoices-new']", text: "Create Invoice")
      expect(page).to have_no_link("Cancel & Go Back")
    end
  end
end
