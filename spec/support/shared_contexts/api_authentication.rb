# frozen_string_literal: true

# A persisted ApiClient and its bearer Authorization header, for API request
# specs. Both are lazy, so examples that do not make an authenticated request
# never create the record.
RSpec.shared_context "api authentication" do
  let(:api_client) { create(:api_client) }
  let(:auth_headers) { { "Authorization" => "Bearer #{api_client.plain_text_token}" } }
end
