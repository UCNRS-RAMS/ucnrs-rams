require "rails_helper"

RSpec.describe "Viewing Passwords", type: :system, js: true do
  describe "when on the sign in page" do
    it "is possible when the icon is clicked" do
      flow = AuthenticationFlow.new(page)

      flow.visit_sign_in_page
      expect(flow).to be_hiding_contents_of_field("Password")

      flow.show_password
      expect(flow).to_not be_hiding_contents_of_field("Password")

      flow.hide_password
      expect(flow).to be_hiding_contents_of_field("Password")
    end
  end

  describe "when resetting a password" do
    it "is possible to view the password and confirmation" do
      user = FactoryBot.create(:user, :confirmed)
      flow = AuthenticationFlow.new(page)

      flow.visit_forgot_password_page
      sleep 0.5
      flow.reset_password_for(user.email)
      sleep 0.5
      flow.follow_reset_password_email_link

      expect(flow).to be_hiding_contents_of_field("Create a New Password")
      expect(flow).to be_hiding_contents_of_field("Re-enter Password")

      flow.show_password("Create a New Password")
      expect(flow).to_not be_hiding_contents_of_field("Create a New Password")

      flow.hide_password("Create a New Password")
      expect(flow).to be_hiding_contents_of_field("Create a New Password")

      flow.show_password("Re-enter Password")
      expect(flow).to_not be_hiding_contents_of_field("Re-enter Password")

      flow.hide_password("Re-enter Password")
      expect(flow).to be_hiding_contents_of_field("Re-enter Password")
    end
  end
end
