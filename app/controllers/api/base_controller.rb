# frozen_string_literal: true

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

    attr_reader :current_api_client

    def authenticate_api_client!
      client = ApiClient.authenticate(bearer_token)
      return render_unauthorized if client.nil?

      @current_api_client = client
    end

    def bearer_token
      scheme, token = request.authorization.to_s.split(" ", 2)
      token if scheme&.casecmp("Bearer")&.zero?
    end

    def render_unauthorized
      response.headers["WWW-Authenticate"] = 'Bearer realm="rams-api"'
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
end
