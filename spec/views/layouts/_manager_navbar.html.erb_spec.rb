require "rails_helper"

RSpec.describe "manager navbar", type: :view do
  it "display the manager navbar" do
    user = FactoryBot.create(:user)
    reserve = create(:reserve)
    assign(:presenter, Manager::DashboardShowPresenter.new(reserve: reserve))

    render partial: "layouts/manager_navbar", locals: { current_user: user }

    expect(rendered).to have_link("", href: "/users/sign_out")

    expect(rendered).to have_link("Visits", href: "#")
    expect(rendered).to have_link("Projects", href: "#")
    expect(rendered).to have_link("Invoices", href: "#")
    expect(rendered).to have_link("Reports", href: "#")
    expect(rendered).to have_link("Reserve info", href: "#")
    expect(rendered).to have_link("Users", href: "#")
    expect(rendered).to have_link("Help", href: "#")
  end
end
