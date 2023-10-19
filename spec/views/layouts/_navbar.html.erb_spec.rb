require "rails_helper"

RSpec.describe "navbar", type: :view do
  it "display the signed in navbar" do
    user = FactoryBot.create(:user)
    layout_presenter = LayoutPresenter.new(
      current_user: user,
      current_reserve: nil,
      controller_path: nil,
      dashboard: nil
    )

    render partial: 'layouts/navbar', locals: { layout_presenter: layout_presenter }

    expect(rendered).to have_link("Visits", href: "/")
    expect(rendered).to have_link("Reserves", href: "/reserves")
    expect(rendered).to have_link("Projects", href: "/projects")
    expect(rendered).to have_link("Help", href: "https://ramshelp.ucnrs.org/")
    expect(rendered).to have_link("My Profile", href: "/users/edit")
    expect(rendered).to have_link("Sign Out", href: "/users/sign_out")

    expect(rendered).to have_link("Schedule a Visit", href: "/visits/new")
  end

  it "display the signed out navbar" do
    user = nil
    layout_presenter = LayoutPresenter.new(
      current_user: user,
      current_reserve: nil,
      controller_path: nil,
      dashboard: nil
    )

    render partial: 'layouts/navbar', locals: { layout_presenter: layout_presenter }

    expect(rendered).to have_link("Reserves", href: "/reserves")
    expect(rendered).to have_link("Search", href: "#")
    expect(rendered).to have_link("Schedule a Visit", href: "/visits/new")

    expect(rendered).not_to have_link("Visits")
    expect(rendered).not_to have_link("Projects")
    expect(rendered).not_to have_link("Help")
    expect(rendered).not_to have_link("My Profile")
  end
end
