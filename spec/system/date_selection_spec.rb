require "rails_helper"

RSpec.describe "Date Selection", type: :system, js: true do
  it "can select start and end dates from a calendar" do
    user = create(:user)
    user.confirm
    sign_in(user)

    flow = DateSelectionFlow.new(page)

    flow.visit_new_visit_page
    expect(flow).to have_no_open_calendar_modal
    expect(page).to be_axe_clean

    freeze_time do
      now = Time.current
      current_month_name = now.strftime("%B")
      next_month_name = (now + 1.month).strftime("%B")
      current_month_number = now.strftime("%m")
      next_month_number = (now + 1.month).strftime("%m")
      tomorrow = (now + 1.day).strftime("%d")
      yesterday = (now - 1.day).strftime("%d")
      current_year = now.year

      flow.click_calendar_icon_for("arrival")
      expect(flow).to have_open_calendar_modal
      expect(flow).to have_displayed_calendar_for("#{current_month_name} #{current_year}")
      expect(page).to be_axe_clean

      flow.select_date(
        mm: current_month_number,
        dd: yesterday,
        yyyy: current_year,
      )
      flow.close_modal
      expect(flow).to have_no_open_calendar_modal
      expect(flow).to have_date_input_value(
        field: "Arrival",
        value: "",
      )
      expect(page).to be_axe_clean

      flow.click_calendar_icon_for("arrival")
      expect(flow).to have_open_calendar_modal
      expect(flow).to have_displayed_calendar_for("#{current_month_name} #{current_year}")
      flow.select_date(
        mm: current_month_number,
        dd: tomorrow,
        yyyy: current_year,
      )
      flow.close_modal
      expect(flow).to have_no_open_calendar_modal
      expect(flow).to have_date_input_value(
        field: "Arrival",
        value: "#{current_month_number}/#{tomorrow}/#{current_year}",
      )

      flow.click_calendar_icon_for("departure")
      expect(flow).to have_open_calendar_modal
      expect(flow).to have_displayed_calendar_for("#{current_month_name} #{current_year}")

      flow.go_to_next_month
      expect(flow).to have_displayed_calendar_for("#{next_month_name} #{current_year}")
      expect(page).to be_axe_clean

      flow.select_date(
        mm: next_month_number,
        dd: "15",
        yyyy: current_year,
      )
      flow.close_modal
      expect(flow).to have_no_open_calendar_modal
      expect(flow).to have_date_input_value(
        field: "Departure",
        value: "#{next_month_number}/15/#{current_year}",
      )
    end
  end
end
