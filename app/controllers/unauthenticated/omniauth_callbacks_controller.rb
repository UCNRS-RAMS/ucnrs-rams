module Unauthenticated
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def orcid
      if orcid_identifier.present?
        redirect_to callback_destination(orcid: orcid_identifier, orcid_callback: "1")
      else
        redirect_to callback_destination(orcid_auth_error: "missing_orcid", orcid_callback: "1")
      end
    end

    def failure
      redirect_to callback_destination(orcid_auth_error: params[:message], orcid_callback: "1")
    end

    private

    def orcid_identifier
      request.env.dig("omniauth.auth", "uid").presence
    end

    def callback_destination(params = {})
      uri = URI.parse(safe_origin_path)
      query = Rack::Utils.parse_nested_query(uri.query).merge(params.compact)

      uri.query = query.to_query
      uri.to_s
    end

    def safe_origin_path
      origin = request.env["omniauth.origin"].presence ||
        request.env.dig("omniauth.params", "origin").presence
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
