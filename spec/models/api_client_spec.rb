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

  describe "access scope" do
    it "allows a platform-wide client without reserve assignments" do
      expect(client).to be_platform_wide
      expect(client.reserves).to be_empty
    end

    it "allows a client scoped to one reserve" do
      reserve = create(:reserve)
      scoped_client = create(:api_client, platform_wide: false, reserves: [ reserve ])

      expect(scoped_client.reserves).to contain_exactly(reserve)
    end

    it "allows a client scoped to multiple reserves" do
      reserves = create_list(:reserve, 2)
      scoped_client = create(:api_client, platform_wide: false, reserves: reserves)

      expect(scoped_client.reserves).to contain_exactly(*reserves)
    end

    it "rejects a non-platform-wide client without assigned reserves" do
      scoped_client = build(:api_client, platform_wide: false)

      expect(scoped_client).not_to be_valid
      expect(scoped_client.errors[:reserves]).to be_present
    end

    it "rejects a platform-wide client with reserve assignments" do
      scoped_client = build(:api_client, reserves: [ create(:reserve) ])

      expect(scoped_client).not_to be_valid
      expect(scoped_client.errors[:reserves]).to be_present
    end
  end
end
