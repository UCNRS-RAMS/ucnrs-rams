require "rails_helper"
require "carrierwave/test/matchers"

RSpec.describe PersonnelUploader do
  include CarrierWave::Test::Matchers

  let(:reserve_personnel) { create(:reserve_personnel) }
  let(:uploader) { described_class.new(reserve_personnel) }

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
      expect(uploader.store_dir).to match(
        "reserve_id_#{reserve_personnel.reserve_id}/#{reserve_personnel.class.to_s.underscore}/
        #{reserve_personnel.id}".squish.delete(" ")
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

  describe "the medium version" do
    it "scales down an image to be 200 by 200 pixels" do
      expect(uploader.medium).to have_dimensions(200, 200)
    end
  end

  describe "the small version" do
    it "scales down an image to be 100 by 100 pixels" do
      expect(uploader.small).to have_dimensions(100, 100)
    end
  end
end
