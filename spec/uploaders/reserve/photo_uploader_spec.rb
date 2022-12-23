require "rails_helper"
require "carrierwave/test/matchers"

RSpec.describe Reserve::PhotoUploader do
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
