require "rails_helper"

RSpec.describe "Registration" do
  describe "creating an account" do
    it "allows the user to view a form to create their account", js: true do
      flow = RegistrationFlow.new(page)

      flow.visit_sign_up_page

      expect(flow).to be_on_sign_up_page
      expect(flow).to have_form
      expect(page).to be_axe_clean
    end
  end
end
