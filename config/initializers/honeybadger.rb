# frozen_string_literal: true

# Honeybadger is optional infrastructure: an unreadable credentials file must
# not prevent the application from booting. Credentials win; the environment is
# the fallback for deployments that inject the key as a secret. Blank values
# from either source leave reporting disabled.
api_key = begin
  Rails.application.credentials.dig(:honeybadger, :api_key)
rescue StandardError => e
  Rails.logger.warn("Honeybadger API key unavailable from Rails credentials: #{e.message}")
  nil
end

Honeybadger.configure do |config|
  config.api_key = api_key.presence || ENV["HONEYBADGER_API_KEY"].presence

  # Zero identifiable data: never ship request payloads, cookies/session, Rack
  # environment (headers, IP, user agent), URLs, breadcrumbs (application logs
  # and SQL), or Insights events (SQL, controller params, HTTP URLs, job
  # arguments). Only the error class, message, and backtrace are reported.
  # This block is the highest-precedence config source, so these assignments
  # override any honeybadger.yml or environment configuration.
  config.request.disable_params = true
  config.request.disable_session = true
  config.request.disable_environment = true
  config.request.disable_url = true
  config.breadcrumbs.enabled = false
  config.insights.enabled = false
end
