require "rails_helper"
require "carrierwave/test/matchers"

RSpec.describe ReserveUploader do
  include CarrierWave::Test::Matchers

  let(:reserve) { create(:reserve) }
  let(:uploader) { described_class.new(reserve) }

  before do
    described_class.enable_processing = true
    File.open(Rails.root.join("spec", "support", "assets", "test-image.jpeg")) do |f|
      uploader.store!(f)
    end
  end

  after do
    described_class.enable_processing = false
    uploader.remove!
  end

  describe "#store_dir" do
    it "creates the correct store directory path for the test environment" do
      expect(uploader.store_dir).to match(/\/tmp\/ucnrs-test\/reserve_id_#{reserve.id}\//)
    end
  end

  describe "#cache_dir" do
    it "creates the correct cache directory path for the test environment" do
      expect(uploader.cache_dir).to match(/\/tmp\/ucnrs-test\/cache\/reserve_id_#{reserve.id}\//)
    end
  end

  describe "#default_url" do
    it "is the correct default url" do
      uploader = described_class.new

      expect(uploader.default_url).to match(/assets\/reserve_placeholder/)
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

  describe "the medium version" do
    it "scales down an image to be 270 by 165 pixels" do
      expect(uploader.medium).to have_dimensions(270, 165)
    end
  end

  describe "the small version" do
    it "scales down an image to be 150 by 100 pixels" do
      expect(uploader.small).to have_dimensions(150, 100)
    end
  end
end
