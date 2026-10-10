require "rails_helper"

RSpec.describe "Manager dashboard calendar", type: :system do
  it "opens the modal when a calendar bar is clicked", js: true do
    reserve = create(:reserve)
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)
    visit_record = create(:visit, reserve: reserve)
    create(:user_visit, visit: visit_record, user: user)

    sign_in(user)
    visit "/manager/reserves/#{reserve.id}/dashboard/calendar"

    expect(page).not_to have_css("#modal.visible")

    first("a.cal-entry").click

    expect(page).to have_css("#modal.visible")
    within "#modal" do
      expect(page).to have_content("Visit ##{visit_record.id}")
      click_button "Close"
    end

    expect(page).not_to have_css("#modal.visible")
  end

  it "keeps the modal's section headings at their own size", js: true do
    reserve = create(:reserve)
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)
    visit_record = create(:visit, reserve: reserve)
    create(:user_visit, visit: visit_record, user: user)

    sign_in(user)
    visit "/manager/reserves/#{reserve.id}/dashboard/calendar"
    first("a.cal-entry").click

    expect(page).to have_css("#modal.visible .cal-visit-section-head h3")
    heading_style = page.evaluate_script(<<~JS)
      (() => {
        const style = getComputedStyle(document.querySelector("#modal .cal-visit-section-head h3"))
        return [style.fontSize, style.fontWeight, style.marginTop, style.marginBottom]
      })()
    JS
    expect(heading_style).to eq [ "11px", "600", "0px", "0px" ]
  end

  it "closes the modal from the keyboard", js: true do
    reserve = create(:reserve)
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)
    visit_record = create(:visit, reserve: reserve)
    create(:user_visit, visit: visit_record, user: user)

    sign_in(user)
    visit "/manager/reserves/#{reserve.id}/dashboard/calendar"
    first("a.cal-entry").click

    expect(page).to have_css("#modal.visible")

    close_button = find("button.cal-visit-close")
    close_button.send_keys(:enter)

    expect(page).not_to have_css("#modal.visible")
  end

  describe "when the calendar is accessed" do
    it "is styled after clicking the tab on the dashboard", js: true do
      reserve = create(:reserve)
      sign_in_manager_of(reserve)

      visit "/manager/reserves/#{reserve.id}/dashboard"
      find("#calendar a").click

      expect_styled_calendar
    end

    it "is styled after clicking the tab on the visit list", js: true do
      reserve = create(:reserve)
      sign_in_manager_of(reserve)

      visit "/manager/reserves/#{reserve.id}/dashboard/visits"
      find("#calendar a").click

      expect_styled_calendar
    end

    it "is styled on a direct load", js: true do
      reserve = create(:reserve)
      sign_in_manager_of(reserve)

      visit "/manager/reserves/#{reserve.id}/dashboard/calendar"

      expect_styled_calendar
    end

    def sign_in_manager_of(reserve)
      user = create(:user, :confirmed)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)
    end

    def expect_styled_calendar
      expect(page).to have_css("header.content-header #calendar a.active")
      expect(page).to have_css("turbo-frame#dashboard-content .reserve-calendar .cal-pill")
      styles = page.evaluate_script(<<~JS)
        [
          getComputedStyle(document.querySelector("header.content-header")).display,
          getComputedStyle(document.querySelector(".cal-pill")).borderTopLeftRadius,
        ]
      JS
      expect(styles).to eq [ "flex", "16px" ]
    end
  end

  it "changes month inside the grid, advances the URL, and comes back", js: true do
    reserve = create(:reserve)
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)

    sign_in(user)
    visit "/manager/reserves/#{reserve.id}/dashboard/calendar?month=5&year=2026"
    expect(page).to have_css("span.cal-day[id='2026-05-15']")
    title = page.title

    first("a.next-month").click

    expect(page).to have_css("span.cal-day[id='2026-06-15']")
    expect(page).to have_current_path(/[?&]month=6(&|\z)/)
    expect(page).to have_css("header.content-header #calendar a.active")
    expect(page.title).to eq title

    page.go_back

    expect(page).to have_css("span.cal-day[id='2026-05-15']")
    expect(page).to have_css("header.content-header #calendar a.active")
  end
end
