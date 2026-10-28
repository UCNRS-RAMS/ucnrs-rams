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

  def has_selected_country_option_for?(select_field:, country_name:)
    page.has_select?(select_field, selected: country_name)
  end

  def has_no_selected_option_for?(select_field)
    page.has_select?(select_field, selected: "")
  end

  def has_correct_state_options_for?(select_field:, country_name:)
    state_names = Country.find_by(name: country_name)
      .states
      .order(:name)
      .pluck(:name) || []
    options = page.find("##{select_field}").all("option").collect(&:text)

    state_names == options.reject(&:empty?)
  end

  def change_country_to(select_field:, country_name:)
    select_first_matching_option(select_field: select_field, option_text: country_name)
  end

  private

  def select_first_matching_option(select_field:, option_text:)
    select = page.find("##{select_field}")
    option = select.all("option").find { |candidate| candidate.text == option_text }
    raise Capybara::ElementNotFound, "Could not find option '#{option_text}' in ##{select_field}" unless option

    option.select_option
  end

  attr_reader :page
end
