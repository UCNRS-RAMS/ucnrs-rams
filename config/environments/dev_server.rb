require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Log to STDOUT by default

  config.lograge.enabled = true
  # Logstash formatter produces a LogStash::Event-compatible JSON envelope,
  # which is the standard our group uses for OpenSearch ingestion.
  # Requires the logstash-event gem.
  config.lograge.formatter = Lograge::Formatters::Logstash.new

  # Include controller info in the available log payload
  config.lograge.custom_payload do |controller|
    {
      # host: controller.request.host,
      ip: controller.request.ip,
      user_id: controller.current_user.try(:id),
    }
  end

  # Skip the health check endpoint — the load balancer pings it constantly and it's noisy.
  # This matches the route: get "up" => "rails/health#show"
  config.lograge.ignore_actions = ['rails/health#show']

  config.lograge.custom_options = ->(event) do
    params_to_skip = %w[_method action authenticity_token commit controller format id]
    event_time = event.time.respond_to?(:iso8601) ? event.time : Time.at(event.time.to_f).utc

    {
      time: event_time.iso8601(6), # ISO8601 string for proper JSON/OpenSearch timestamp
      params: (event.payload[:params] || {}).except(*params_to_skip),
    }
  end

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :request_id ]

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "ucnrs_rams_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Use letter_opener to preview emails in browser instead of sending them
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.perform_deliveries = true

  # External URL settings for links in emails/routes.
  app_host = ENV.fetch("MAILER_HOST", ENV.fetch("HOST", "rams-dev.uc3dev.cdlib.net"))
  app_protocol = ENV.fetch("MAILER_PROTOCOL", ENV.fetch("PROTOCOL", "https"))
  app_port = ENV["MAILER_PORT"].presence # do NOT fall back to internal PORT

  default_port = app_protocol == "https" ? 443 : 80

  url_options = {
    host: app_host,
    protocol: app_protocol,
  }.tap do |options|
    if app_port.present? && app_port.to_i != default_port
      options[:port] = app_port.to_i
    end
  end

  config.action_mailer.default_url_options = url_options
  Rails.application.routes.default_url_options = url_options

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  # Note: this applies to non-request log lines (startup, ActiveRecord, etc.).
  # Lograge handles request lines and formats them as JSON.
  config.log_formatter = ::Logger::Formatter.new

  # Always log to STDOUT in this environment so logs are captured by the container
  # runtime and forwarded to OpenSearch.
  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
