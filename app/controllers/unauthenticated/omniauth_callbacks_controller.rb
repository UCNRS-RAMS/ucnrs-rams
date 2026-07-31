require 'http'

module Unauthenticated
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    ORCID_IDENTIFIER_PATTERN = /\A\d{4}-\d{4}-\d{4}-[\dX]{4}\z/i
    ORCID_PROVIDER = "orcid"
    REGISTRATION_ORCID_SESSION_KEY = :registration_orcid_identifier

    def orcid

      # Don't leave this logging by default, but it is very useful when troubleshooting login or API tokens.
      # Comment out when not needed.
      log_orcid_auth_info

      if orcid_identifier.present?
        session[REGISTRATION_ORCID_SESSION_KEY] = orcid_identifier
        redirect_to callback_destination(orcid_callback: "1")
      else
        flash[:alert] = I18n.t("devise.omniauth_callbacks.orcid_failure")
        redirect_to callback_destination(orcid_auth_error: "missing_orcid", orcid_callback: "1")
      end
    end

    def failure
      flash[:alert] = I18n.t("devise.omniauth_callbacks.orcid_failure")
      redirect_to callback_destination(orcid_auth_error: params[:message], orcid_callback: "1")
    end

    private

    def orcid_identifier
      normalize_orcid_identifier(orcid_auth_hash&.dig("uid").presence)
    end

    def log_orcid_auth_info
      auth_hash = orcid_auth_hash
      if auth_hash.present?
        Rails.logger.info "[ORCID OAuth] auth hash: #{auth_hash.to_hash.inspect}"
        token = auth_hash.dig('credentials', 'token')
        Rails.logger.info "[ORCID OAuth] access token: #{token}"
        orcid_identifier = auth_hash["uid"]

        if token.present? && orcid_identifier.present?
          %w[2.0 2.1 3.0].each do |api_version|
            success, name = test_authenticated_request(api_version: api_version, token: token, orcid: orcid_identifier)
            if success
              Rails.logger.info "[ORCID OAuth] API v#{api_version} authenticated request successful. name: #{name}"
            else
              Rails.logger.info "[ORCID OAuth] API v#{api_version} authenticated request failed."
            end
          end
        else
          Rails.logger.info "[ORCID OAuth] access token or orcid uid is not present in auth hash"
        end

      else
        Rails.logger.info "[ORCID OAuth] no auth hash present in request.env"
      end
    end

    def orcid_auth_hash
      auth_hash = request.env["omniauth.auth"]
      return if auth_hash.blank?

      provider = auth_hash["provider"].to_s
      return auth_hash if provider.casecmp?(ORCID_PROVIDER)

      Rails.logger.warn "[ORCID OAuth] unexpected OmniAuth provider=#{provider.inspect}; ignoring auth hash"
      nil
    end

    def normalize_orcid_identifier(raw_identifier)
      return if raw_identifier.blank?

      identifier = raw_identifier.to_s
        .strip
        .sub(%r{\Ahttps?://orcid\.org/}i, "")
        .split(/[?#]/)
        .first
        .to_s
        .delete_suffix("/")

      identifier if identifier.match?(ORCID_IDENTIFIER_PATTERN)
    end

    def orcid_sandbox?
      ActiveModel::Type::Boolean.new.cast(ENV["ORCID_USE_SANDBOX"])
    end

    def callback_destination(params = {})
      uri = URI.parse(safe_origin_path)
      query = Rack::Utils.parse_nested_query(uri.query).merge(params.compact)

      uri.query = query.to_query
      uri.to_s
    end

    def safe_origin_path
      origin = request.env["omniauth.origin"].presence ||
        request.env.dig("omniauth.params", "origin").presence ||
        params[:origin].presence
      return new_user_registration_path if origin.blank?

      uri = URI.parse(origin)
      path = uri.path.to_s
      return new_user_registration_path if uri.host.present? || uri.scheme.present?
      return new_user_registration_path unless path.start_with?("/") && !path.start_with?("//")

      "#{path}#{uri.query.present? ? "?#{uri.query}" : ""}"
    rescue URI::InvalidURIError
      new_user_registration_path
    end

    # A simple test of api version(s) to see that authenticated call with orcid token works and returns basic data
    def test_authenticated_request(api_version:, token:, orcid:)
      api_host = orcid_sandbox? ? "api.sandbox.orcid.org" : "api.orcid.org"
      base_url = "https://#{api_host}/v#{api_version}"
      url = "#{base_url}/#{orcid}/record"

      # Chain authorization and header definitions
      response = HTTP.auth("Bearer #{token}").accept(:json).get(url)

      if response.status.success?
        data = response.parse

        person_name = data.dig('person', 'name')  # for some reason name seems to be null in json orcid returns sometimes
        return [true, person_name]
      else
        return [false, nil]
      end
    end
  end
end
