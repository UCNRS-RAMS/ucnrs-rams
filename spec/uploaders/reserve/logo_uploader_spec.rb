require "rails_helper"
require "carrierwave/test/matchers"

RSpec.describe Reserve::LogoUploader do
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
