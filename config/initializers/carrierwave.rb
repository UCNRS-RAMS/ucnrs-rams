require "carrierwave/orm/activerecord"

CarrierWave.configure do |config|
  config.root = "#{Rails.public_path}".freeze
  config.fog_credentials = {
    provider: "AWS",
    aws_access_key_id: ENV["AWS_ACCESS_KEY"],
    aws_secret_access_key: ENV["AWS_SECRET_KEY"],
    region: ENV["AWS_REGION"],
  }
  config.fog_directory = ENV["BUCKET_NAME"]
  config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
end

if Rails.env.development?
  CarrierWave.configure do |config|
    config.storage = :file
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
  end
end


