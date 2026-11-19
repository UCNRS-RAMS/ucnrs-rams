require "uri"

# Capybara 3.40 resets Chrome storage with a wildcard origin, which Chrome 158 rejects.
# Remove this workaround when Capybara ships the fix for teamcapybara/capybara#2865.
module ChromeStorageReset
  private

  def execute_cdp(command, params = {})
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => error
    raise unless command == "Storage.clearDataForOrigin" && params[:origin] == "*" &&
      error.message.include?("* is not a valid URL")

    delete_all_cookies
    return unless params[:storageTypes].include?("local_storage")

    origins = execute_cdp("Page.getNavigationHistory").fetch("entries").filter_map do |entry|
      url = URI.parse(entry.fetch("url"))
      url.origin if url.is_a?(URI::HTTP)
    end
    origins.uniq.each do |origin|
      super(command, { origin: origin, storageTypes: "local_storage" })
    end
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageReset)

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    # If you don't want headless (for troubleshooting), use :selenium_chrome
    # driven_by :selenium_chrome
    #
    # Keep headless committed, only use alternatives for troubleshooting
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
      options.add_argument("--no-sandbox")
      options.add_argument("--disable-dev-shm-usage")
    end
    Capybara.current_session.current_window.resize_to(1000, 1000)
  end
end
