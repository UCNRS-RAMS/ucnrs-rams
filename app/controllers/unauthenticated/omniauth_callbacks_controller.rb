module Unauthenticated
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    ORCID_IDENTIFIER_PATTERN = /\A\d{4}-\d{4}-\d{4}-[\dX]{4}\z/i
    REGISTRATION_ORCID_SESSION_KEY = :registration_orcid_identifier

    def orcid
      if orcid_identifier.present?
        session[REGISTRATION_ORCID_SESSION_KEY] = orcid_identifier
        redirect_to callback_destination(orcid_callback: "1")
      else
        redirect_to callback_destination(orcid_auth_error: "missing_orcid", orcid_callback: "1")
      end
    end

    def failure
      redirect_to callback_destination(orcid_auth_error: params[:message], orcid_callback: "1")
    end

    private

    def orcid_identifier
      auth = request.env["omniauth.auth"] || request.env[:"omniauth.auth"]
      uid = auth&.[]("uid").presence || auth&.[](:uid).presence

      normalize_orcid_identifier(uid)
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
  end
end
