require "rails_helper"

RSpec.describe "footer", type: :view do
  it "renders the footer" do
    render partial: "layouts/footer"

    expect(rendered).to have_link("UCNRS.ORG")
    expect(rendered).to have_link("Sign Up for the Newsletter")

    expect(rendered).to have_link("Terms of Use")
    expect(rendered).to have_link("Privacy Policy")
  end
end
