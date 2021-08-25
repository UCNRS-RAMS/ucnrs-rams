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
    page.click_link("Forgot your password?")
  end

  def reset_password_for(email)
    page.fill_in("Email", with: email)
    page.find("input[type='submit']").click
  end

  def follow_reset_password_email_link
    email_delivery = ActionMailer::Base.deliveries.last
    match = email_delivery.body.match(%r{/users/password/edit\?reset_password_token=[\w-]+})
    if match.present?
      page.visit(match[0])
    end
  end

  def reset_password_to(new_password)
    page.fill_in("New password", with: new_password)
    page.fill_in("Confirm new password", with: new_password)
    page.find("input[type='submit']").click
  end

  def has_confirmed_email_is_valid?
    page.has_content?("Your password has been changed successfully.")
  end

  def visit_homepage
    page.visit("/")
  end

  def fill_out_account_creation_form(email:, password:)
    page.fill_in("Email", with: email)
    page.fill_in("Password", with: password)
    page.fill_in("Password confirmation", with: password)
    page.find("input[type='submit']").click
  end

  def confirm_email
    email_delivery = ActionMailer::Base.deliveries.last
    match = email_delivery.body.match(%r{/users/confirmation\?confirmation_token=[\w-]+})
    if match.present?
      page.visit(match[0])
    end
  end

  def has_confirmed_email_is_valid?
    page.has_content?("Your email address has been successfully confirmed.")
  end
  
  def sign_in_as(email:, password:)
    page.fill_in("Email", with: email)
    page.fill_in("Password", with: password)
    page.find("input[type='submit']").click
  end

  def sign_out
    page.find("a", text: "Sign Out").click
  end

  def signed_in?
    page.has_css?("body.home")
  end

  def on_sign_in_page?
    page.has_css?("body.sessions.sessions-new")
  end

  private

  attr_reader :page
end
