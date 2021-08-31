class RegistrationFlow
  def initialize(page)
    @page = page
  end

  def visit_sign_up_page
    page.visit("/users/sign_up")
  end

  def on_sign_up_page?
    page.has_css?("body.registrations.registrations-new")
  end

  def has_form?
    page.has_css?("form")
  end

  private

  attr_reader :page
end
