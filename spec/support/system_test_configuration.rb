RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    # If you don't want headless (for troubleshooting), use :selenium_chrome
    # driven_by :selenium_chrome
    #
    # Keep headless committed, only use alternatives for troubleshooting
    driven_by :selenium_chrome_headless
  end
end
