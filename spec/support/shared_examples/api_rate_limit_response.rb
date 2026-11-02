# frozen_string_literal: true

# Counter behavior (including cross-controller limits and expiry) is covered
# by request specs. This declares the common contract for every API operation.
RSpec.shared_examples "API rate limit response" do
  response "429", "client or unauthenticated IP quota exceeded" do
    schema "$ref" => "#/components/schemas/Error"
    header "Retry-After", schema: { type: :integer },
      description: "Conservative wait in seconds before retrying."

    let(:id) { 0 }

    before do
      allow(Api::BaseController.cache_store).to receive(:increment)
        .and_return(Api::BaseController::RATE_LIMIT + 1)
    end

    run_test! do |response|
      expect(response.parsed_body).to eq("error" => "rate_limit_exceeded")
      expect(response.headers["Retry-After"]).to eq("60")
    end
  end
end
