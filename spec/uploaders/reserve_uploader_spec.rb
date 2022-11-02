require "rails_helper"

RSpec.describe ReserveUploader do
  describe "#store_dir" do
    it "creates the correct store directory path for the test environment" do
      reserve = create(:reserve)
      uploader = described_class.new(reserve)

      expect(uploader.store_dir).to match(/\/tmp\/ucnrs-test\/reserve_id_#{reserve.id}\//)
    end
  end

  describe "#cache_dir" do
    it "creates the correct cache directory path for the test environment" do
      reserve = create(:reserve)
      uploader = described_class.new(reserve)

      expect(uploader.cache_dir).to match(/\/tmp\/ucnrs-test\/cache\/reserve_id_#{reserve.id}\//)
    end
  end

  describe "#default_url" do
    it "is the correct default url" do
      uploader = described_class.new

      expect(uploader.default_url).to match(/assets\/reserve_placeholder/)
    end
  end
end
