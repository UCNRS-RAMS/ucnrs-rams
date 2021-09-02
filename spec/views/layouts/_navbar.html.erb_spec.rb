require "rails_helper"

RSpec.describe "navbar", type: :view do
  it "display the signed in navbar" do
    user = FactoryBot.create(:user)

    render partial: 'layouts/navbar', locals: { current_user: user }

    expect(rendered).to have_link("Visits")
    expect(rendered).to have_link("Reserves")
    expect(rendered).to have_link("My Projects")
    expect(rendered).to have_link("Help")
    expect(rendered).to have_link("Account")

    expect(rendered).to have_link("Schedule a Visit")
  end

  it "display the signed out navbar" do
    user = nil

    render partial: 'layouts/navbar', locals: { current_user: user }

    expect(rendered).not_to have_link("Visits")
    expect(rendered).not_to have_link("Reserves")
    expect(rendered).not_to have_link("My Projects")
    expect(rendered).not_to have_link("Help")
    expect(rendered).not_to have_link("Account")

    expect(rendered).not_to have_link("Schedule a Visit")
  end
end