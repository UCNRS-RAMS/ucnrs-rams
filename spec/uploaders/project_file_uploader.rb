require "rails_helper"
require "carrierwave/test/matchers"

RSpec.describe ProjectFileUploader do
  include CarrierWave::Test::Matchers

  let(:project) { create(:project) }
  let(:uploader) { described_class.new(project) }

  before do
    described_class.enable_processing = true
    File.open(Rails.root.join("spec", "support", "assets", "test-file.pdf")) do |f|
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
        "uploads/#{project.class.to_s.underscore}//#{project.id}"
      )
    end
  end

  describe "#filename" do
    it "return filename" do
      expect(uploader.file.filename).to match("test-file_#{Date.current}.pdf")
    end
  end

  describe "#date" do
    it "return upload date of file" do
      expect(uploader.date).to match("#{Date.current}")
    end
  end

  describe "#name" do
    it "return name of file" do
      expect(uploader.name).to match("test-file.pdf")
    end
  end
end
