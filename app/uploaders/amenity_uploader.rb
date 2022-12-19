class AmenityUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    [
      ("uploads" if Rails.env.development?),
      "reserve_id_#{model.reserve_id || 'null'}",
      "#{model.class.to_s.underscore}",
      "#{mounted_as}",
      "#{model.id || 'null'}",
    ].compact_blank.join("/")
  end

  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  def content_type_allowlist
    [/image\//]
  end

  version :medium do
    process resize_to_fill: [270,165]
  end

  version :small, from: :medium do
    process resize_to_fill: [150,100]
  end
end
