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
    config.root = "#{Rails.root.join("tmp/ucnrs-test")}".freeze
    config.cache_dir = "uploads/cache".freeze
  end
end

if %w[dev_server staging production].include?(Rails.env)
  CarrierWave.configure do |config|
    config.storage = :fog
    config.root = Rails.public_path.to_s.freeze

    fog_creds = {
      provider: "AWS",
      region: ENV.fetch("AWS_REGION", "us-west-2") # Fallback to default region
    }

    # Only manually inject keys if they are explicitly provided in the environment for an external server.
    # If running within the same AWS Account for ECS and S3 then access can be provided with policies and
    # CloudFormation rather than embedding external AWS access values.
    if ENV["AWS_ACCESS_KEY"].present? && ENV["AWS_SECRET_KEY"].present?
      fog_creds[:aws_access_key_id] = ENV["AWS_ACCESS_KEY"]
      fog_creds[:aws_secret_access_key] = ENV["AWS_SECRET_KEY"]
    else
      # This triggers fog/AWS SDK to use the ECS Task Role automatically
      fog_creds[:use_iam_profile] = true
    end

    config.fog_credentials = fog_creds
    config.fog_directory = ENV.fetch("BUCKET_NAME", nil)
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
  end

end
