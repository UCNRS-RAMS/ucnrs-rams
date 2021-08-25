require "rails_helper"

RSpec.describe FooterComponent, type: :component do
  it "renders the FooterComponent" do
    component = FooterComponent.new

    render_inline(component)

    expect(rendered_component).to have_link("Facebook")
    expect(rendered_component).to have_link("Instagram")
    expect(rendered_component).to have_link("YouTube")
    expect(rendered_component).to have_link("UCNRS.ORG")
    expect(rendered_component).to have_link("Sign Up for the Newsletter")

    expect(rendered_component).to have_link("Terms of Use")
    expect(rendered_component).to have_link("Privacy Policy")
  end
end
