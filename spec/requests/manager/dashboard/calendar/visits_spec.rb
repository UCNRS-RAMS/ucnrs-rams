require "rails_helper"

RSpec.describe Manager::Dashboard::Calendar::VisitsController, type: :request do
  describe "GET /manager/reserves/:reserve_id/dashboard/calendar/visits/:id" do
    it "renders the modal frame so Turbo swaps it into the layout's modal" do
      reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar/visits/#{visit.id}",
        params: { kind: "user", row_id: "42" }

      page = Capybara.string(response.body)
      expect(response).to be_ok
      expect(page).to have_css(
        "turbo-frame#modal-content [data-modal-target~='openOnLoad']", visible: :all
      )
      expect(page).to have_css("#modal-title", text: "Visit ##{visit.id}", visible: :all)
    end

    it "does not serve a visit belonging to another reserve" do
      reserve = create(:reserve)
      other_reserve = create(:reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      other_visit = create(:visit, reserve: other_reserve)
      sign_in(user)

      get "/manager/reserves/#{reserve.id}/dashboard/calendar/visits/#{other_visit.id}"

      expect(response).to be_not_found
    end

    describe "dialog" do
      it "supplies the label the frame points at, without a second dialog role" do
        page = Capybara.string(show_modal.body)

        expect(page).to have_css("turbo-frame#modal-content #modal-title", visible: :all)
        expect(page).to have_no_css("turbo-frame#modal-content [role='dialog']", visible: :all)
      end

      it "closes with a real button rather than the image the placeholder used" do
        page = Capybara.string(show_modal.body)

        button = page.find("button.cal-visit-close", visible: :all)
        expect(button["data-action"]).to eq("click->modal#close")
        expect(button["aria-label"]).to be_present
        expect(button["title"]).to eq("Close")
      end
    end

    describe "the content column" do
      it "heads the modal with the visit id, reserve, status and project type" do
        page = Capybara.string(show_modal(status: :approved).body)

        expect(page).to have_css(
          "#modal-title", text: "Visit ##{@visit.id} · #{@reserve.name}", visible: :all
        )
        expect(page).to have_css(".cal-visit-pill-approved", text: "Approved", visible: :all)
        expect(page).to have_css(".cal-visit-pill-type", text: "Research", visible: :all)
      end

      it "links the purpose out of the modal to the full visit page" do
        page = Capybara.string(show_modal.body)

        link = page.find(".cal-visit-purpose", visible: :all)
        expect(link.text).to include("Try to take over the world")
        expect(link["href"]).to eq("/manager/reserves/#{@reserve.id}/visits/#{@visit.id}")
        expect(link["data-turbo-frame"]).to eq("_top")
      end

      it "lists each visitor with initials, role and the arrival/departure pair" do
        visitor = create(:user, first_name: "Yun", last_name: "Zhao")
        create(
          :user_visit,
          visit: visit_record,
          user: visitor,
          role: :graduate_student,
          arrives_at: Time.zone.parse("2026-07-07 17:00"),
          departs_at: Time.zone.parse("2026-08-13 08:00"),
        )

        page = Capybara.string(show_modal.body)
        row = page.find(".cal-visit-rows .cal-visit-row", visible: :all)

        expect(row).to have_css(".cal-visit-avatar", text: "YZ", visible: :all)
        expect(row).to have_css(".cal-visit-row-name", text: "Yun Zhao", visible: :all)
        expect(row).to have_css(".cal-visit-row-sub", text: "Graduate Student", visible: :all)
        expect(row.text).to include("07 Jul, 5pm").and include("13 Aug, 8am")
      end

      it "counts people rather than rows in the visitors heading" do
        create(:user_visit, visit: visit_record, count: 4)

        page = Capybara.string(show_modal.body)

        expect(page).to have_css(
          "[aria-labelledby='cal-visit-visitors-heading'] .cal-visit-section-count",
          text: "4", visible: :all
        )
      end

      it "lists each amenity with its units and a link to the invoice" do
        amenity = create(:amenity, reserve: reserve_record, title: "Safety kit", units_type: "unit")
        amenity_visit = create(:amenity_visit, visit: visit_record, amenity: amenity, number_of_people: 2)

        page = Capybara.string(show_modal.body)
        row = page.find(".cal-visit-row-amenity", visible: :all)

        expect(row).to have_css(".cal-visit-row-name", text: "Safety kit", visible: :all)
        expect(row).to have_css(".cal-visit-row-units", text: "×2 units", visible: :all)
        expect(row.find("a", visible: :all)["href"]).to eq(
          "/manager/reserves/#{reserve_record.id}/invoices/#{amenity_visit.invoice_id}"
        )
      end

      it "shows the reserve's most recent note on the visit" do
        create(:reserve_note, record: visit_record, reserve: reserve_record,
                              note: "Older note", created_at: 2.days.ago)
        create(:reserve_note, record: visit_record, reserve: reserve_record,
                              note: "Gate code changed", created_at: 1.hour.ago)

        page = Capybara.string(show_modal.body)

        expect(page).to have_css(".cal-visit-note", text: "Gate code changed", visible: :all)
        expect(page).to have_no_css(".cal-visit-note", text: "Older note", visible: :all)
      end

      it "omits the note block when the visit has none" do
        page = Capybara.string(show_modal.body)

        expect(page).to have_no_css(".cal-visit-note", visible: :all)
      end
    end

    describe "right side section" do
      it "shows the schedule and the night count" do
        page = Capybara.string(
          show_modal(
            starts_at: Time.zone.parse("2026-07-07 17:00"),
            ends_at: Time.zone.parse("2026-08-13 08:00"),
          ).body
        )

        rail = page.find(".cal-visit-rail", visible: :all)
        expect(rail).to have_css(".cal-visit-schedule-value", text: "07 Jul, 5:00 pm", visible: :all)
        expect(rail).to have_css(".cal-visit-schedule-value", text: "13 Aug, 8:00 am", visible: :all)
        expect(rail).to have_css(".cal-visit-schedule-nights", text: "37 nights", visible: :all)
      end

      it "shows the year on both ends of a visit that crosses new year" do
        page = Capybara.string(
          show_modal(
            starts_at: Time.zone.parse("2026-12-28 17:00"),
            ends_at: Time.zone.parse("2027-01-03 08:00"),
          ).body
        )

        rail = page.find(".cal-visit-rail", visible: :all)
        expect(rail).to have_css(".cal-visit-schedule-value", text: "28 Dec 2026, 5:00 pm", visible: :all)
        expect(rail).to have_css(".cal-visit-schedule-value", text: "03 Jan 2027, 8:00 am", visible: :all)
      end

      it "shows the project number, title and owner" do
        institution = create(:institution, name: "SUNY — Environmental Science and Forestry")
        owner = create(:user, first_name: "John", last_name: "Stella", institution: institution)
        visit_record.project.update!(title: "Riparian tree coring", owner: owner)

        page = Capybara.string(show_modal.body)
        rail = page.find(".cal-visit-rail", visible: :all)

        expect(rail).to have_css(
          ".cal-visit-rail-label", text: "Project ##{visit_record.project_id}", visible: :all
        )
        expect(rail).to have_link("Riparian tree coring", visible: :all)
        expect(rail).to have_css(".cal-visit-rail-label", text: "Owner", visible: :all)
        expect(rail).to have_css(".cal-visit-rail-name", text: "John Stella", visible: :all)
        expect(rail).to have_css(
          ".cal-visit-rail-sub", text: "SUNY — Environmental Science and Forestry", visible: :all
        )
      end

      it "falls back rather than blanking when the owner no longer resolves" do
        visit_record.project.update_column(:user_id, 0) # rubocop:disable Rails/SkipsModelValidations

        page = Capybara.string(show_modal.body)

        expect(page).to have_css(".cal-visit-rail-label", text: "Owner", visible: :all)
        expect(page).to have_css(".cal-visit-rail-sub", text: "Not recorded", visible: :all)
      end
    end

    def reserve_record
      @reserve ||= create(:reserve)
    end

    def visit_record
      @visit ||= create(:visit, reserve: reserve_record)
    end

    def show_modal(**visit_attributes)
      visit_record.update!(visit_attributes) if visit_attributes.any?

      manager = create(:user, :confirmed)
      create(:reserve_personnel, user: manager, reserve: reserve_record)
      sign_in(manager)

      get "/manager/reserves/#{reserve_record.id}/dashboard/calendar/visits/#{visit_record.id}"
      response
    end
  end
end
