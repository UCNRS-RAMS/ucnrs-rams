# frozen_string_literal: true

# Namespace for the token-authenticated JSON API.
module Api
  # Base controller for JSON API endpoints. Authenticates the caller with a
  # Bearer token issued to an ApiClient. Doorkeeper can replace this hook later
  # without changing endpoint controllers.
  class BaseController < ActionController::API
    # Shared across API resources and token rotations, not per reserve or route.
    RATE_LIMIT = Integer(ENV.fetch("API_RATE_LIMIT", "300"), 10)
    raise ArgumentError, "API_RATE_LIMIT must be positive" unless RATE_LIMIT.positive?

    before_action :identify_api_client
    rate_limit to: RATE_LIMIT, within: 1.minute, scope: "api",
      by: :rate_limit_identity, with: :render_rate_limit_exceeded
    before_action :authenticate_api_client!

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "not_found" }, status: :not_found
    end

    private

    # @return [ApiClient, nil] the client authenticated for the current request
    attr_reader :current_api_client

    # @return [void]
    def identify_api_client
      @current_api_client = ApiClient.authenticate(bearer_token)
    end

    # @return [void]
    def authenticate_api_client!
      render_unauthorized unless current_api_client
    end

    # Invalid credentials share an IP bucket; arbitrary tokens cannot create
    # arbitrary buckets. Valid clients behind the same NAT remain independent.
    # @return [String]
    def rate_limit_identity
      current_api_client ? "client:#{current_api_client.id}" : "ip:#{request.remote_ip}"
    end

    # Retry-After is a conservative full window, not an exact reset timestamp.
    # @return [void]
    def render_rate_limit_exceeded
      response.headers["Retry-After"] = "60"
      render json: { error: "rate_limit_exceeded" }, status: :too_many_requests
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
