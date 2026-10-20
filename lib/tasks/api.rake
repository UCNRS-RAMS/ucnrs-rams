# frozen_string_literal: true

namespace :api do
  namespace :clients do
    desc "Create an API client and print its token (shown once; store it securely)"
    task create: :environment do
      name = ENV.fetch("NAME")
      platform_wide = ENV["PLATFORM_WIDE"] == "true"
      reserve_ids = ENV.fetch("RESERVE_IDS", "").split(",").map(&:strip).reject(&:blank?)

      if platform_wide && reserve_ids.any?
        raise ArgumentError, "Set either PLATFORM_WIDE=true or RESERVE_IDS, not both"
      end

      if !platform_wide && reserve_ids.empty?
        raise ArgumentError, "Must specify either PLATFORM_WIDE=true or RESERVE_IDS"
      end

      client = ApiClient.create!(name: name, platform_wide: platform_wide, reserve_ids: reserve_ids)

      puts "Created API client #{client.id} (#{client.name})"
      puts "Token: #{client.plain_text_token}"
    end
  end
end
