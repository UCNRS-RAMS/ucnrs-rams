class AuthenticationFlow
  def initialize(page)
    @page = page
  end

  def visit_sign_in_page
    page.visit("/users/sign_in")
  end

  def visit_sign_up_page
    page.visit("/users/sign_up")
  end

  def visit_forgot_password_page
    visit_sign_in_page
    page.click_link("Forgot Password")
  end

  def reset_password_for(email)
    ActionMailer::Base.deliveries.clear
    page.fill_in("Email", with: email)
    page.find("input[type='submit']").click
  end

  def follow_reset_password_email_link
    email_delivery = wait_for_last_email
    match = email_delivery.body.match(%r{/users/password/edit\?reset_password_token=[\w-]+})
    raise "Reset password email missing token link" unless match.present?

    page.visit(match[0])
  end

  def reset_password_to(new_password)
    page.fill_in("Create a New Password", with: new_password)
    page.fill_in("Re-enter Password", with: new_password)
    page.find("input[type='submit']").click
  end

  def has_confirmed_email_is_valid?
    page.has_content?("Your password has been changed successfully.")
  end

  def visit_homepage
    page.visit("/home")
  end

  def fill_out_account_creation_form(email:, password:)
    ActionMailer::Base.deliveries.clear
    page.fill_in("Email", with: email)
    page.fill_in("Password", with: password)
    page.fill_in("Password confirmation", with: password)
    page.find("input[type='submit']").click
  end

  def confirm_email
    page.has_content?("A message with a confirmation link")

    if email_delivery.nil?
      raise "Confirmation email was not delivered. Deliveries: #{ActionMailer::Base.deliveries.size}"
    end

    match = email_delivery.body.match(%r{/users/confirmation\?confirmation_token=[\w-]+})
  end

  def sign_in_as(email:, password:)
    page.fill_in("Email", with: email)
    page.fill_in("Password", with: password)
    page.find("input[type='submit']").click
  end

  def dismiss_modal
    page.find(".modal button.active", text: "Let's go!").click
  end

  def hiding_contents_of_field?(field_name)
    label = page.find("label", text: field_name)
    input = page.find("##{label['for']}")
    input["type"] == "password"
  end

  def show_password(field_name = "Password")
    label = page.find("label", text: field_name)
    page
      .find("##{label['for']}")
      .find(:xpath, ".//..")
      .find("img.input-icon")
      .click
  end

  alias_method :hide_password, :show_password

  def sign_out
    page.find_link(href: "/users/sign_out").click
  end

  def signed_in?
    page.has_css?("body.home") || page.has_css?("body.dashboard")
  end

  def on_sign_in_page?
    page.has_css?("body.sessions.sessions-new")
  end

  private

  attr_reader :page

  def wait_for_last_email(context_label = "reset password")
    deadline = Time.now + Capybara.default_max_wait_time

    loop do
      email_delivery = ActionMailer::Base.deliveries.last
      return email_delivery if email_delivery
      raise "Timed out waiting for #{context_label} email" if Time.now >= deadline

      sleep 0.1
    end
  end
end
