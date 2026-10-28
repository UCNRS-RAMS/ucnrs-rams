require "rails_helper"

RSpec.describe "Manager dashboard calendar", type: :system do
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
