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
end
