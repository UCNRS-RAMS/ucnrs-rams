require "rails_helper"

RSpec.describe ApiClient, type: :model do
  describe "token generation" do
    it "exposes the plaintext token once and persists only its digest" do
      client = create(:api_client)

      expect(client.plain_text_token).to be_present
      expect(client.token_digest).to be_present
      expect(client.token_digest).not_to eq(client.plain_text_token)

      reloaded = described_class.find(client.id)

      expect(reloaded.plain_text_token).to be_nil
      expect(reloaded.token_digest).to eq(client.token_digest)
    end
  end

  describe ".authenticate" do
    it "returns the client for a valid token" do
      client = create(:api_client)

      expect(described_class.authenticate(client.plain_text_token)).to eq(client)
    end

    it "returns nil for a blank or unknown token" do
      create(:api_client)

      expect(described_class.authenticate(nil)).to be_nil
      expect(described_class.authenticate("")).to be_nil
      expect(described_class.authenticate("not-a-real-token")).to be_nil
    end

    it "returns nil for an inactive client" do
      client = create(:api_client, active: false)

      expect(described_class.authenticate(client.plain_text_token)).to be_nil
    end
  end

  describe "#projects" do
    it "returns all projects when the client is unscoped" do
      project = create(:project)
      client = create(:api_client)

      expect(client.projects).to include(project)
    end

    it "returns only the reserve's projects when scoped" do
      reserve = create(:reserve)
      included_project = create(:project, reserve: reserve)
      excluded_project = create(:project)
      client = create(:api_client, reserve: reserve)

      expect(client.projects).to include(included_project)
      expect(client.projects).not_to include(excluded_project)
    end
  end

  describe "#rotate_token!" do
    it "issues a new token and invalidates the old one" do
      client = create(:api_client)
      old_token = client.plain_text_token

      client.rotate_token!

      expect(client.plain_text_token).not_to eq(old_token)
      expect(described_class.authenticate(client.plain_text_token)).to eq(client)
      expect(described_class.authenticate(old_token)).to be_nil
    end
  end
end
