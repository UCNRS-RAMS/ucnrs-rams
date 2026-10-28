require "rails_helper"

RSpec.describe "Registration" do
  describe "creating an account" do
    it "allows a user to dynamically select states based on the selected country", js: true do
      us = create(:country, name: "United States")
      create(:state, name: "California", country: us)
      create(:state, name: "Massachusetts", country: us)
      uk = create(:country, name: "United Kingdom")
      create(:state, name: "Avon", country: uk)
      create(:state, name: "Yorkshire", country: uk)
      create(:country, name: "Zimbabwe", states: [])
      flow = RegistrationFlow.new(page)

      flow.visit_sign_up_page
      expect(flow).to be_on_sign_up_page
      expect(flow).to have_selected_country_option_for(select_field: "user_address_country_id", country_name: "United States")
      expect(flow).to have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United States")
      expect(flow).to_not have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United Kingdom")

      flow.change_country_to(country_name: "United Kingdom", select_field: "user_address_country_id")
      expect(flow).to have_selected_country_option_for(select_field: "user_address_country_id", country_name: "United Kingdom")
      expect(flow).to have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United Kingdom")
      expect(flow).to_not have_correct_state_options_for(select_field: "user_address_state_id", country_name: "United States")
      expect(page).to be_axe_clean

      expect(flow).to have_selected_country_option_for(select_field: "user_billing_address_country_id", country_name: "United States")
      expect(flow).to have_no_selected_option_for("user_billing_address_state_id")
      expect(page).to be_axe_clean.skipping(:"color-contrast")

      flow.change_country_to(country_name: "Zimbabwe", select_field: "user_billing_address_country_id")
      expect(flow).to have_selected_country_option_for(select_field: "user_billing_address_country_id", country_name: "Zimbabwe")
      expect(flow).to have_correct_state_options_for(select_field: "user_billing_address_state_id", country_name: "Zimbabwe")
      expect(page).to be_axe_clean.skipping(:"color-contrast")
    end
  end
end
