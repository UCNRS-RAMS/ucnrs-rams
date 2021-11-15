require "rails_helper"

RSpec.describe "navbar", type: :view do
  it "display the signed in navbar" do
    user = FactoryBot.create(:user)

    render partial: 'layouts/navbar', locals: { current_user: user }

    expect(rendered).to have_link("Visits", href: "/")
    expect(rendered).to have_link("Reserves", href: "/reserves")
    expect(rendered).to have_link("My Projects", href: "/projects")
    expect(rendered).to have_link("Help", href: "#")
    expect(rendered).to have_link("Account", href: "#")
    expect(rendered).to have_link("Sign Out", href: "/users/sign_out")

    expect(rendered).to have_link("Schedule a Visit", href: "/visits/new")
  end

  it "display the signed out navbar" do
    user = nil

    render partial: 'layouts/navbar', locals: { current_user: user }

    expect(rendered).to have_link("Reserves", href: "/reserves")
    expect(rendered).to have_link("Search", href: "#")
    expect(rendered).to have_link("Schedule a Visit", href: "/visits/new")

    expect(rendered).not_to have_link("Visits")
    expect(rendered).not_to have_link("My Projects")
    expect(rendered).not_to have_link("Help")
    expect(rendered).not_to have_link("Account")
  end
end
