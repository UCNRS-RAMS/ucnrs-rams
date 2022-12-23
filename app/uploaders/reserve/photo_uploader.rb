class Reserve::PhotoUploader < ReserveUploader
  include CarrierWave::MiniMagick

  version :medium do
    process resize_to_fill: [270,165]
  end

  version :small, from: :medium do
    process resize_to_fill: [150,100]
  end
end
