require "rails_helper"

RSpec.describe NavbarComponent, type: :component do
  it "renders the NavbarComponent" do
    component = NavbarComponent.new(user: :fake_user)

    render_inline(component)

    expect(rendered_component).to have_link("Visits")
    expect(rendered_component).to have_link("Reserves")
    expect(rendered_component).to have_link("My Projects")
    expect(rendered_component).to have_link("Help")
    expect(rendered_component).to have_link("Account")

    expect(rendered_component).to have_link("Schedule a Visit")
  end
end
