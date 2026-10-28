RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # Shakapacker's digest check can report a fresh build while the referenced
  # pack files are missing or stale. That silently disables Stimulus/Turbo and
  # turns every browser example into a confusing "element not found" failure,
  # so fail fast with an actionable message instead.
  config.before(:each, type: :system, js: true) do
    pack = Shakapacker.manifest.lookup!("application.js")
    pack_path = Rails.public_path.join(pack.delete_prefix("/"))
    unless pack_path.exist?
      raise "Compiled test JavaScript is missing at #{pack_path}. " \
        "Run `bin/shakapacker` (or `bundle exec rails assets:precompile`) before running browser specs."
    end
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
