require "rails_helper"
require "carrierwave/test/matchers"

RSpec.describe ReserveUploader do
  include CarrierWave::Test::Matchers

  let(:reserve) { create(:reserve) }
  let(:uploader) { described_class.new(reserve) }

  before do
    described_class.enable_processing = true
    File.open(Rails.root.join("spec/support/assets/test-image.jpeg")) do |f|
      uploader.store!(f)
    end
  end

  after do
    described_class.enable_processing = false
    uploader.remove!
  end

  describe "#store_dir" do
    it "creates the correct store directory path for the test environment" do
      expect(uploader.store_dir).to match(
        "reserve_id_#{reserve.id}/reserve_info"
      )
    end
  end

  describe "#cache_dir" do
    it "creates the correct cache directory path for the test environment" do
      expect(uploader.cache_dir).to match(/uploads\/cache/)
    end
  end

  describe "#extension_allowlist" do
    it "returns an array of image extensions" do
      expect(uploader.extension_allowlist).to eq(%w[jpg jpeg gif png])
    end
  end

  describe "#content_type_allowlist" do
    it "returns an array of of patterns for allowed content types" do
      expect(uploader.content_type_allowlist).to eq([/image\//])
    end
  end
end
