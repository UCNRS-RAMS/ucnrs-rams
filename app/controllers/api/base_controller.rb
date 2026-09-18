# frozen_string_literal: true

# Namespace for the token-authenticated JSON API.
module Api
  # Base controller for JSON API endpoints. Authenticates the caller with a
  # Bearer token issued to an ApiClient. Doorkeeper can replace this hook later
  # without changing endpoint controllers.
  class BaseController < ActionController::API
    before_action :authenticate_api_client!

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "not_found" }, status: :not_found
    end

    private

    # @return [ApiClient, nil] the client authenticated for the current request
    attr_reader :current_api_client

    # @return [void]
    def authenticate_api_client!
      client = ApiClient.authenticate(bearer_token)
      return render_unauthorized if client.nil?

      @current_api_client = client
    end

    # @return [String, nil] the token from a well-formed +Bearer+ header, or nil
    def bearer_token
      scheme, token = request.authorization.to_s.split(" ", 2)
      token if scheme&.casecmp("Bearer")&.zero?
    end

    # @return [void]
    def render_unauthorized
      response.headers["WWW-Authenticate"] = 'Bearer realm="rams-api"'
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
