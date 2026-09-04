# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    before_action :authenticate_api!

    private

    def authenticate_api!
      scheme, token = request.authorization.to_s.split(" ", 2)
      expected_token = ENV["RAMS_API_TOKEN"].to_s

      return if scheme == "Bearer" && expected_token.present? &&
        ActiveSupport::SecurityUtils.secure_compare(token.to_s, expected_token)

      response.set_header("WWW-Authenticate", 'Bearer realm="RAMS API"')
      head :unauthorized
    end
  end
end
