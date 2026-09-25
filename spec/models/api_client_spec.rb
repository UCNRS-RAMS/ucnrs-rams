require "rails_helper"

RSpec.describe ApiClient, type: :model do
  let(:client) { create(:api_client) }

  describe "token generation" do
    it "generates a plaintext token on creation" do
      expect(client.plain_text_token).to be_present
    end

    it "stores the SHA-256 digest of the token" do
      expect(client.token_digest).to eq(described_class.digest_for(client.plain_text_token))
    end

    it "never persists the plaintext token" do
      reloaded = described_class.find(client.id)

      expect(reloaded.plain_text_token).to be_nil
    end

    it "prefixes the token so it is recognizable in logs and secret stores" do
      expect(client.plain_text_token).to start_with(described_class::TOKEN_PREFIX)
    end

    it "issues a different token to each client" do
      other = create(:api_client)

      expect(client.plain_text_token).not_to eq(other.plain_text_token)
    end
  end

  describe ".authenticate" do
    it "returns the client for a valid token" do
      expect(described_class.authenticate(client.plain_text_token)).to eq(client)
    end

    it "returns nil for a blank token" do
      expect(described_class.authenticate(nil)).to be_nil
      expect(described_class.authenticate("")).to be_nil
    end

    it "returns nil for an unknown token" do
      expect(described_class.authenticate("not-a-real-token")).to be_nil
    end

    context "when the client is inactive" do
      let(:client) { create(:api_client, active: false) }

      it "returns nil" do
        expect(described_class.authenticate(client.plain_text_token)).to be_nil
      end
    end

    context "when the token has been rotated" do
      # let! so the original token is read before the rotation below.
      let!(:original_token) { client.plain_text_token }

      before { client.rotate_token! }

      it "rejects the old token" do
        expect(described_class.authenticate(original_token)).to be_nil
      end

      it "accepts the new token" do
        expect(described_class.authenticate(client.plain_text_token)).to eq(client)
      end
    end
  end

  describe "#rotate_token!" do
    it "replaces the existing token" do
      original_token = client.plain_text_token

      client.rotate_token!

      expect(client.plain_text_token).not_to eq(original_token)
    end

    it "returns the client" do
      expect(client.rotate_token!).to eq(client)
    end
  end

  describe "reserve scoping" do
    it "leaves the reserve unset for a platform-wide client" do
      expect(client.reserve).to be_nil
    end

    context "when the client is scoped to a reserve" do
      let(:reserve) { create(:reserve) }
      let(:client) { create(:api_client, reserve: reserve) }

      it "records the reserve" do
        expect(client.reserve).to eq(reserve)
      end
    end
  end
end
