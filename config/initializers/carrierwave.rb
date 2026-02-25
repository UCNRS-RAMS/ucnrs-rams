require "carrierwave/orm/activerecord"

if Rails.env.development?
  CarrierWave.configure do |config|
    config.storage = :file
    config.root = Rails.public_path.to_s.freeze
  end
end

if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/tmp/ucnrs-test".freeze
    config.cache_dir = "uploads/cache".freeze
  end
end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.root = Rails.public_path.to_s.freeze
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY", nil),
      aws_secret_access_key: ENV.fetch("AWS_SECRET_KEY", nil),
      region: ENV.fetch("AWS_REGION", nil),
    }
    config.fog_directory = ENV.fetch("BUCKET_NAME", nil)
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
  end
end
