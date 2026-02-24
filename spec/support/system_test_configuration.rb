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
