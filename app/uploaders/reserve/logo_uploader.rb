class Reserve::LogoUploader < ReserveUploader
  include CarrierWave::MiniMagick

  version :medium do
    process resize_to_fill: [200,200]
  end

  version :small do
    process resize_to_fill: [100,100]
  end
end
