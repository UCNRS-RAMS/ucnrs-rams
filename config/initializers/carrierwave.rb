require "carrierwave/orm/activerecord"

if Rails.env.development?
  CarrierWave.configure do |config|
    config.storage = :file
  end
end

if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
end

if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage = :fog
  end
end

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: "AWS",
    aws_access_key_id: ENV["AWS_ACCESS_KEY"],
    aws_secret_access_key: ENV["AWS_SECRET_KEY"],
    region: ENV["AWS_REGION"],
  }
  config.fog_directory = ENV["BUCKET_NAME"]
  config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }

  # Auto-load Uploader classes
  ReserveUploader

  # Use different, explicit store_ and cache_ dirs when testing
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/tmp/ucnrs-test/cache/"
      end

      def store_dir
        "#{Rails.root}/tmp/ucnrs-test/"
      end
    end
  end
end
