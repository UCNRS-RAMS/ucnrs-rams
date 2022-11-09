class ReserveUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    [
      ("uploads" if Rails.env.development?),
      "reserve_id_#{model.id}/",
    ].join("/")
  end

  def cache_dir
    [
      "tmp",
      "reserve_id_#{model.id || 'null'}/",
    ].join("/")
  end

  def default_url(*args)
    ActionController::Base.helpers.asset_path("reserve_placeholder.jpg")
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
